/**
 * Database migration script.
 * Run once with: node src/db/migrate.js
 * Creates all tables and seeds one demo employee.
 */
const pool = require('./pool');

async function migrate() {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // ──────────────────────────────────────────────
    // 1. employees
    // ──────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS employees (
        id              SERIAL PRIMARY KEY,
        first_name      VARCHAR(50)  NOT NULL,
        last_name       VARCHAR(50)  NOT NULL,
        email           VARCHAR(150) UNIQUE NOT NULL,
        phone_number    VARCHAR(20),
        designation     VARCHAR(80),
        is_active       BOOLEAN      DEFAULT TRUE,
        password_hash   VARCHAR(255),
        is_first_login  BOOLEAN      DEFAULT TRUE,
        created_at      TIMESTAMPTZ  DEFAULT NOW(),
        updated_at      TIMESTAMPTZ  DEFAULT NOW()
      );
    `);

    // Add columns if they don't exist (for existing databases)
    await client.query(`ALTER TABLE employees ADD COLUMN IF NOT EXISTS password_hash  VARCHAR(255);`);
    await client.query(`ALTER TABLE employees ADD COLUMN IF NOT EXISTS is_first_login BOOLEAN DEFAULT TRUE;`);

    // ──────────────────────────────────────────────
    // 2. attendance_records  (one row per day per employee)
    // ──────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS attendance_records (
        id               SERIAL PRIMARY KEY,
        employee_id      INT         NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
        work_date        DATE        NOT NULL,
        check_in_time    TIMESTAMPTZ,
        check_out_time   TIMESTAMPTZ,
        working_minutes  INT         GENERATED ALWAYS AS (
                           CASE
                             WHEN check_in_time IS NOT NULL AND check_out_time IS NOT NULL
                             THEN EXTRACT(EPOCH FROM (check_out_time - check_in_time))::INT / 60
                             ELSE NULL
                           END
                         ) STORED,
        overtime_minutes INT         DEFAULT 0,
        late_minutes     INT         DEFAULT 0,
        status           VARCHAR(20) DEFAULT 'absent'
                                     CHECK (status IN ('present','absent','half_day','on_leave')),
        zone             VARCHAR(80) DEFAULT 'Tech Hub South',
        auth_method      VARCHAR(30) DEFAULT 'Biometric/NFC',
        notes            TEXT,
        check_in_selfie_url  TEXT,
        check_out_selfie_url TEXT,
        created_at       TIMESTAMPTZ DEFAULT NOW(),
        updated_at       TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE (employee_id, work_date)
      );
    `);

    // Ensure columns exist on existing databases
    await client.query(`
      ALTER TABLE attendance_records 
      ADD COLUMN IF NOT EXISTS check_in_selfie_url TEXT,
      ADD COLUMN IF NOT EXISTS check_out_selfie_url TEXT;
    `);

    // ──────────────────────────────────────────────
    // 3. activity_logs  (granular in/out events)
    // ──────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS activity_logs (
        id            SERIAL PRIMARY KEY,
        employee_id   INT         NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
        event_type    VARCHAR(30) NOT NULL
                                  CHECK (event_type IN ('check_in','check_out','break_start','break_end','session_resume')),
        event_time    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        zone          VARCHAR(80),
        workstation   VARCHAR(50),
        auth_method   VARCHAR(30) DEFAULT 'Biometric/NFC',
        created_at    TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // ──────────────────────────────────────────────
    // 4. auto-update updated_at trigger
    // ──────────────────────────────────────────────
    await client.query(`
      CREATE OR REPLACE FUNCTION set_updated_at()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    `);

    for (const tbl of ['employees', 'attendance_records']) {
      await client.query(`
        DROP TRIGGER IF EXISTS trg_${tbl}_updated_at ON ${tbl};
        CREATE TRIGGER trg_${tbl}_updated_at
        BEFORE UPDATE ON ${tbl}
        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
      `);
    }

    // ──────────────────────────────────────────────
    // 5. Demo seed – fixed accounts (idempotent)
    // ──────────────────────────────────────────────
const demoUsers = [
      ['Aarthi', 'S',     'aarthiarunachalamk@gmail.com', 'Senior Developer', 'BB-TempPass@2026'],
      ['Admin',  'User',  'admin@bitbyte.tech',           'HR Admin',         'Admin@1234'],
      ['Super',  'Admin', 'superadmin@bitbyte.tech',      'Super Admin',      'Super@1234'],
    ];

    for (const [firstName, lastName, email, desig, pass] of demoUsers) {
      await client.query(`
        INSERT INTO employees (first_name, last_name, email, designation, password_hash, is_first_login)
        VALUES ($1, $2, $3, $4, $5, FALSE)
        ON CONFLICT (email) DO UPDATE
          SET password_hash  = EXCLUDED.password_hash,
              is_first_login = FALSE;
      `, [firstName, lastName, email, desig, pass]);
    }

    await client.query('COMMIT');
    console.log('✅  Migration complete — all tables created.');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌  Migration failed:', err.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

migrate();
