require('dotenv').config();
const express    = require('express');
const cors       = require('cors');
const path       = require('path');
const pool       = require('./db/pool');

const employeeRoutes   = require('./routes/employees');
const attendanceRoutes = require('./routes/attendance');
const authRoutes       = require('./routes/auth');

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// ── Health check
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', db: 'connected', timestamp: new Date().toISOString() });
  } catch (err) {
    res.status(503).json({ status: 'error', db: 'disconnected', message: err.message });
  }
});

// ── API routes
app.use('/api/employees',  employeeRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/auth',       authRoutes);

// ── 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.method} ${req.path} not found` });
});

// ── Global error handler
app.use((err, req, res, _next) => {
  console.error('Unhandled error:', err.stack);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

// ── Start
app.listen(PORT, () => {
  console.log(`\n🌊  DeepOcean HRMS API running on http://localhost:${PORT}`);
  console.log(`   Health:     GET  /health`);
  console.log(`   Employees:  GET  /api/employees`);
  console.log(`   Check-in:   POST /api/attendance/check-in`);
  console.log(`   Check-out:  POST /api/attendance/check-out`);
  console.log(`   Today:      GET  /api/attendance/today/:employee_id`);
  console.log(`   History:    GET  /api/attendance/history/:employee_id`);
  console.log(`   Activity:   GET  /api/attendance/activity/:employee_id\n`);
});
