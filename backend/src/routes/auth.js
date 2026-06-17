const express = require('express');
const router  = express.Router();
const pool    = require('../db/pool');

// ── POST /api/auth/login
// Body: { email, password }
// Returns: employee data + is_first_login flag
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'Email and password are required' });
  }

  try {
    const { rows } = await pool.query(
      `SELECT id, employee_code, full_name, email, department, designation,
              sector, is_active, is_first_login, password_hash, created_at
       FROM employees
       WHERE LOWER(email) = LOWER($1) AND is_active = TRUE`,
      [email.trim()]
    );

    if (rows.length === 0) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    const emp = rows[0];

    // Simple plain-text comparison (replace with bcrypt in production)
    if (!emp.password_hash || emp.password_hash !== password) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    // Remove sensitive field before sending
    const { password_hash, ...safeEmp } = emp;

    res.json({
      success: true,
      data: {
        ...safeEmp,
        is_first_login: emp.is_first_login ?? true,
      },
    });
  } catch (err) {
    console.error('POST /auth/login error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ── POST /api/auth/change-password
// Body: { email, temp_password, new_password }
router.post('/change-password', async (req, res) => {
  const { email, temp_password, new_password } = req.body;

  if (!email || !temp_password || !new_password) {
    return res.status(400).json({ success: false, message: 'All fields are required' });
  }

  if (new_password.length < 8) {
    return res.status(400).json({ success: false, message: 'Password must be at least 8 characters' });
  }

  try {
    // Verify current (temp) password
    const { rows } = await pool.query(
      `SELECT id, password_hash, is_first_login
       FROM employees
       WHERE LOWER(email) = LOWER($1) AND is_active = TRUE`,
      [email.trim()]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Employee not found' });
    }

    const emp = rows[0];

    if (!emp.password_hash || emp.password_hash !== temp_password) {
      return res.status(401).json({ success: false, message: 'Incorrect temporary password' });
    }

    // Update to new password and mark first login complete
    await pool.query(
      `UPDATE employees
       SET password_hash  = $1,
           is_first_login = FALSE,
           updated_at     = NOW()
       WHERE id = $2`,
      [new_password, emp.id]
    );

    res.json({
      success: true,
      message: 'Password updated successfully. Please log in with your new password.',
    });
  } catch (err) {
    console.error('POST /auth/change-password error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;
