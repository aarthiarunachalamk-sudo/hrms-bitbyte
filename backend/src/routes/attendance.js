const express = require('express');
const router = express.Router();
const multer = require('multer');
const pool = require('../db/pool');
const { uploadSelfie } = require('../services/s3Service');

const upload = multer({ storage: multer.memoryStorage() });

// Shift settings (minutes)
const SHIFT_START_HOUR   = 9;   // 9:00 AM
const GRACE_MINUTES      = 15;
const EXPECTED_MINUTES   = 510; // 8h 30m
const BREAK_MINUTES      = 45;
const OVERTIME_THRESHOLD = 600; // 10h

/**
 * Calculates late_minutes based on check-in time vs 9:00 AM + 15-min grace.
 */
function calcLateMinutes(checkInTime) {
  const ci = new Date(checkInTime);
  const shiftStart = new Date(ci);
  shiftStart.setHours(SHIFT_START_HOUR, GRACE_MINUTES, 0, 0);
  const diff = Math.floor((ci - shiftStart) / 60000);
  return diff > 0 ? diff : 0;
}

/**
 * Calculates overtime_minutes if working minutes exceed OVERTIME_THRESHOLD.
 */
function calcOvertimeMinutes(workingMinutes) {
  if (!workingMinutes) return 0;
  const net = workingMinutes - BREAK_MINUTES;
  return net > OVERTIME_THRESHOLD ? net - OVERTIME_THRESHOLD : 0;
}

// ── POST /api/attendance/check-in
// Body (multipart/form-data): { employee_id, zone?, auth_method?, workstation? } + File: selfie
router.post('/check-in', upload.single('selfie'), async (req, res) => {
  const { employee_id, zone, auth_method, workstation } = req.body;
  const file = req.file;

  const empId = parseInt(employee_id);
  if (isNaN(empId)) {
    return res.status(400).json({ success: false, message: 'employee_id is required and must be a number' });
  }

  if (!file) {
    return res.status(400).json({ success: false, message: 'Selfie photo file is required for check-in' });
  }

  const now = new Date();
  const today = now.toISOString().split('T')[0]; // YYYY-MM-DD

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Ensure employee exists
    const emp = await client.query('SELECT id, first_name, last_name FROM employees WHERE id = $1 AND is_active = TRUE', [empId]);
    if (emp.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ success: false, message: 'Employee not found or inactive' });
    }

    // Prevent double check-in
    const existing = await client.query(
      `SELECT id, check_in_time FROM attendance_records WHERE employee_id = $1 AND work_date = $2`,
      [empId, today]
    );
    if (existing.rows.length > 0 && existing.rows[0].check_in_time) {
      await client.query('ROLLBACK');
      return res.status(409).json({
        success: false,
        message: 'Already checked in today',
        checked_in_at: existing.rows[0].check_in_time,
      });
    }

    // Upload selfie (S3 or local fallback)
    const selfieUrl = await uploadSelfie(file, empId, 'check_in');

    const lateMinutes = calcLateMinutes(now);
    const effectiveZone = zone || 'Tech Hub South';
    const effectiveAuth = auth_method || 'Biometric/NFC';

    // Upsert attendance record for today
    const { rows } = await client.query(
      `INSERT INTO attendance_records
         (employee_id, work_date, check_in_time, status, zone, auth_method, late_minutes, check_in_selfie_url)
       VALUES ($1, $2, $3, 'present', $4, $5, $6, $7)
       ON CONFLICT (employee_id, work_date) DO UPDATE
         SET check_in_time = EXCLUDED.check_in_time,
             status        = 'present',
             zone          = EXCLUDED.zone,
             auth_method   = EXCLUDED.auth_method,
             late_minutes  = EXCLUDED.late_minutes,
             check_in_selfie_url = EXCLUDED.check_in_selfie_url
       RETURNING *`,
      [empId, today, now, effectiveZone, effectiveAuth, lateMinutes, selfieUrl]
    );

    // Write activity log
    await client.query(
      `INSERT INTO activity_logs (employee_id, event_type, event_time, zone, workstation, auth_method)
       VALUES ($1, 'check_in', $2, $3, $4, $5)`,
      [empId, now, effectiveZone, workstation || null, effectiveAuth]
    );

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: `Check-in recorded for ${emp.rows[0].first_name} ${emp.rows[0].last_name}`,
      data: {
        ...rows[0],
        late_minutes: lateMinutes,
      },
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('POST /attendance/check-in error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  } finally {
    client.release();
  }
});

// ── POST /api/attendance/check-out
// Body (multipart/form-data): { employee_id, zone?, auth_method?, workstation? } + File: selfie
router.post('/check-out', upload.single('selfie'), async (req, res) => {
  const { employee_id, zone, auth_method, workstation } = req.body;
  const file = req.file;

  const empId = parseInt(employee_id);
  if (isNaN(empId)) {
    return res.status(400).json({ success: false, message: 'employee_id is required and must be a number' });
  }

  if (!file) {
    return res.status(400).json({ success: false, message: 'Selfie photo file is required for check-out' });
  }

  const now = new Date();
  const today = now.toISOString().split('T')[0];

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Find today's open attendance record
    const record = await client.query(
      `SELECT * FROM attendance_records
       WHERE employee_id = $1 AND work_date = $2`,
      [empId, today]
    );

    if (record.rows.length === 0 || !record.rows[0].check_in_time) {
      await client.query('ROLLBACK');
      return res.status(404).json({ success: false, message: 'No check-in found for today' });
    }

    if (record.rows[0].check_out_time) {
      await client.query('ROLLBACK');
      return res.status(409).json({ success: false, message: 'Already checked out today' });
    }

    // Upload selfie (S3 or local fallback)
    const selfieUrl = await uploadSelfie(file, empId, 'check_out');

    // Compute working & overtime minutes
    const checkInTime = new Date(record.rows[0].check_in_time);
    const rawMinutes = Math.floor((now - checkInTime) / 60000);
    const netMinutes = rawMinutes - BREAK_MINUTES;
    const overtime   = calcOvertimeMinutes(rawMinutes);

    const { rows } = await client.query(
      `UPDATE attendance_records
       SET check_out_time   = $1,
           overtime_minutes = $2,
           check_out_selfie_url = $3
       WHERE employee_id = $4 AND work_date = $5
       RETURNING *`,
      [now, overtime, selfieUrl, empId, today]
    );

    await client.query(
      `INSERT INTO activity_logs (employee_id, event_type, event_time, zone, workstation, auth_method)
       VALUES ($1, 'check_out', $2, $3, $4, $5)`,
      [empId, now, zone || 'Tech Hub South', workstation || null, auth_method || 'Biometric/NFC']
    );

    await client.query('COMMIT');

    // Format hh:mm helper
    const fmt = (mins) => {
      if (mins == null) return '00:00';
      const h = Math.floor(mins / 60).toString().padStart(2, '0');
      const m = (mins % 60).toString().padStart(2, '0');
      return `${h}:${m}`;
    };

    res.json({
      success: true,
      message: 'Check-out recorded',
      data: {
        ...rows[0],
        working_minutes: rows[0].working_minutes,
        working_hours_display: fmt(rows[0].working_minutes),
        overtime_display: fmt(overtime),
      },
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('POST /attendance/check-out error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  } finally {
    client.release();
  }
});

// ── GET /api/attendance/today/:employee_id  – today's record
router.get('/today/:employee_id', async (req, res) => {
  const today = new Date().toISOString().split('T')[0];
  try {
    const { rows } = await pool.query(
      `SELECT ar.*, (e.first_name || ' ' || e.last_name) AS full_name
       FROM attendance_records ar
       JOIN employees e ON e.id = ar.employee_id
       WHERE ar.employee_id = $1 AND ar.work_date = $2`,
      [req.params.employee_id, today]
    );

    if (rows.length === 0) {
      return res.json({ success: true, data: null, message: 'No record yet for today' });
    }

    const r = rows[0];
    const fmt = (mins) => {
      if (mins == null) return '00:00';
      const h = Math.floor(mins / 60).toString().padStart(2, '0');
      const m = (mins % 60).toString().padStart(2, '0');
      return `${h}:${m}`;
    };

    res.json({
      success: true,
      data: {
        ...r,
        working_hours_display: fmt(r.working_minutes),
        overtime_display: fmt(r.overtime_minutes),
        late_display: fmt(r.late_minutes),
      },
    });
  } catch (err) {
    console.error('GET /attendance/today error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ── GET /api/attendance/history/:employee_id?limit=30&offset=0  – paginated history
router.get('/history/:employee_id', async (req, res) => {
  const limit  = parseInt(req.query.limit)  || 30;
  const offset = parseInt(req.query.offset) || 0;

  try {
    const { rows } = await pool.query(
      `SELECT ar.*, (e.first_name || ' ' || e.last_name) AS full_name
       FROM attendance_records ar
       JOIN employees e ON e.id = ar.employee_id
       WHERE ar.employee_id = $1
       ORDER BY ar.work_date DESC
       LIMIT $2 OFFSET $3`,
      [req.params.employee_id, limit, offset]
    );

    const fmt = (mins) => {
      if (mins == null) return '00:00';
      const h = Math.floor(mins / 60).toString().padStart(2, '0');
      const m = (mins % 60).toString().padStart(2, '0');
      return `${h}:${m}`;
    };

    const formatted = rows.map((r) => ({
      ...r,
      working_hours_display: fmt(r.working_minutes),
      overtime_display: fmt(r.overtime_minutes),
      late_display: fmt(r.late_minutes),
    }));

    res.json({ success: true, data: formatted, count: formatted.length });
  } catch (err) {
    console.error('GET /attendance/history error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ── GET /api/attendance/activity/:employee_id?limit=10  – recent activity logs
router.get('/activity/:employee_id', async (req, res) => {
  const limit = parseInt(req.query.limit) || 10;
  try {
    const { rows } = await pool.query(
      `SELECT al.*, (e.first_name || ' ' || e.last_name) AS full_name
       FROM activity_logs al
       JOIN employees e ON e.id = al.employee_id
       WHERE al.employee_id = $1
       ORDER BY al.event_time DESC
       LIMIT $2`,
      [req.params.employee_id, limit]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error('GET /attendance/activity error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;
