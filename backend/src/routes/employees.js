const express = require('express');
const router = express.Router();
const pool = require('../db/pool');

// ── GET /api/employees  – list all active employees
router.get('/', async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT id, first_name, last_name, email, phone_number, designation, is_active, created_at
       FROM employees
       WHERE is_active = TRUE
       ORDER BY first_name`
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    console.error('GET /employees error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ── GET /api/employees/:id  – single employee
router.get('/:id', async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT id, first_name, last_name, email, phone_number, designation, is_active, created_at
       FROM employees WHERE id = $1`,
      [req.params.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Employee not found' });
    }
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('GET /employees/:id error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ── POST /api/employees  – create employee
router.post('/', async (req, res) => {
  const { first_name, last_name, email, phone_number, designation } = req.body;

  if (!first_name || !last_name || !email) {
    return res.status(400).json({ success: false, message: 'first_name, last_name and email are required' });
  }

  try {
    const { rows } = await pool.query(
      `INSERT INTO employees (first_name, last_name, email, phone_number, designation)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [first_name, last_name, email, phone_number || null, designation || null]
    );
    res.status(201).json({ success: true, data: rows[0] });
  } catch (err) {
    if (err.code === '23505') {
      return res.status(409).json({ success: false, message: 'Email already exists' });
    }
    console.error('POST /employees error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ── PUT /api/employees/:id  – update employee
router.put('/:id', async (req, res) => {
  const { first_name, last_name, email, phone_number, designation, is_active } = req.body;
  try {
    const { rows } = await pool.query(
      `UPDATE employees
       SET first_name   = COALESCE($1, first_name),
           last_name    = COALESCE($2, last_name),
           email        = COALESCE($3, email),
           phone_number = COALESCE($4, phone_number),
           designation  = COALESCE($5, designation),
           is_active    = COALESCE($6, is_active)
       WHERE id = $7
       RETURNING *`,
      [first_name, last_name, email, phone_number, designation, is_active, req.params.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Employee not found' });
    }
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('PUT /employees/:id error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});


const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// Ensure database columns exist
async function ensureDbColumns() {
  try {
    await pool.query('ALTER TABLE employees ADD COLUMN IF NOT EXISTS temp_password   VARCHAR(100)');
    await pool.query('ALTER TABLE employees ADD COLUMN IF NOT EXISTS password_hash   VARCHAR(255)');
    await pool.query('ALTER TABLE employees ADD COLUMN IF NOT EXISTS is_first_login  BOOLEAN DEFAULT TRUE');
    await pool.query('ALTER TABLE employees ADD COLUMN IF NOT EXISTS birthday        DATE');
await pool.query('ALTER TABLE employees ADD COLUMN IF NOT EXISTS joining_date    DATE');
    await pool.query('ALTER TABLE employees ADD COLUMN IF NOT EXISTS phone_number    VARCHAR(20)');
  } catch (err) {
    console.error('Error ensuring database columns exist:', err.message);
  }
}

function generateTempPassword() {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%';
  let result = '';
  for (let i = 0; i < 10; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return `BB-${result}`;
}

// Helper to send registration email
async function sendWelcomeEmail(fullName, email, tempPassword) {
  const msg = {
    to: email,
    from: 'senthil.bitbyte@gmail.com',
    subject: 'Welcome to HRMS – Your Temporary Login Credentials',
    html: `
      <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;background:#ffffff;padding:0;border-radius:8px;overflow:hidden;">
        <div style="background:#0284C7;padding:28px 32px;text-align:center;">
          <h1 style="color:#ffffff;font-size:22px;font-weight:800;letter-spacing:2px;margin:0;">HRMS</h1>
          <p style="color:#e0f2fe;font-size:13px;margin:6px 0 0;">BitByte Workforce Management</p>
        </div>
        <div style="padding:32px;">
          <p style="color:#0f172a;font-size:15px;">Hi <strong>${fullName}</strong>,</p>
          <p style="color:#334155;font-size:14px;line-height:1.6;">
            Your HRMS account has been created successfully. Use the temporary password below to log in and <strong>change it immediately</strong> on first login.
          </p>
          <div style="background:#f0f9ff;border:1px solid #bae6fd;border-radius:8px;padding:20px;margin:24px 0;text-align:center;">
            <p style="color:#0284C7;font-size:11px;font-weight:700;letter-spacing:1.5px;margin:0 0 8px;">TEMPORARY PASSWORD</p>
            <p style="color:#0f172a;font-size:22px;font-weight:800;font-family:monospace;letter-spacing:2px;margin:0;">${tempPassword}</p>
          </div>
          <p style="color:#64748b;font-size:13px;line-height:1.6;">
            For your security, you will be asked to update this password on your first login.
          </p>
          <hr style="border:none;border-top:1px solid #e2e8f0;margin:24px 0;"/>
          <p style="color:#94a3b8;font-size:11px;text-align:center;margin:0;">
            This email was sent by BitByte HR System. Please do not reply.
          </p>
        </div>
      </div>
    `,
  };

  try {
    await sgMail.send(msg);
    console.log(`✉️  Welcome Email successfully sent to ${email}`);
    return { success: true, previewUrl: null };
  } catch (err) {
    console.error('Error sending welcome email:', err.response?.body || err.message);
    return { success: false, error: err.message };
  }
}
// ── POST /api/employees/signup  – employee registration & password generation
router.post('/signup', async (req, res) => {
  const { firstName, lastName, email, phoneNumber, designation, birthday, joiningDate } = req.body;

  if (!firstName || !lastName || !email || !phoneNumber || !designation || !birthday || !joiningDate) {
    return res.status(400).json({
      success: false,
      message: 'firstName, lastName, email, phoneNumber, designation, birthday and joiningDate are required',
    });
  }

  const fullName = `${firstName} ${lastName}`; // only used for the welcome email greeting
  const tempPassword = generateTempPassword();

  try {
    // Ensure table structure has necessary columns
    await ensureDbColumns();

    // Insert new employee record
    const { rows } = await pool.query(
      `INSERT INTO employees (first_name, last_name, email, phone_number, designation, birthday, joining_date, temp_password, password_hash, is_first_login)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $8, TRUE)
       RETURNING *`,
      [firstName, lastName, email, phoneNumber, designation, birthday, joiningDate, tempPassword]
    );

    // Send welcome email with password via nodemailer
    const emailResult = await sendWelcomeEmail(fullName, email, tempPassword);

    res.status(201).json({
      success: true,
      data: {
        employee: rows[0],
        tempPassword: tempPassword,
        emailPreviewUrl: emailResult.previewUrl || null,
        emailSent: emailResult.success,
      },
    });
  } catch (err) {
    if (err.code === '23505') {
      return res.status(409).json({ success: false, message: 'An employee with this email already exists' });
    }
    console.error('POST /employees/signup error:', err.message);
    res.status(500).json({ success: false, message: 'Server error during registration' });
  }
});

module.exports = router;

