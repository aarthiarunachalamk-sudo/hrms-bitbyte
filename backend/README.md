# DeepOcean HRMS — Node.js Backend

REST API built with **Express** + **PostgreSQL** (`pg` pool).

## Folder structure

```
backend/
├── src/
│   ├── db/
│   │   ├── pool.js       – pg connection pool
│   │   └── migrate.js    – one-time schema setup + seed
│   ├── routes/
│   │   ├── employees.js  – CRUD for employees
│   │   └── attendance.js – check-in, check-out, history
│   └── server.js         – Express entry point
├── .env.example
└── package.json
```

## Quick start

### 1. PostgreSQL

Create a database:
```sql
CREATE DATABASE hrms_db;
```

### 2. Environment

```bash
cp .env.example .env
# edit .env with your DB credentials
```

### 3. Install & migrate

```bash
cd backend
npm install
node src/db/migrate.js   # creates tables + 1 demo employee
```

### 4. Run

```bash
npm run dev    # nodemon (hot-reload)
# or
npm start      # plain node
```

Server starts at **http://localhost:3000**.

---

## API Reference

<!-- ### Health -->

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | DB connectivity check |

### Employees

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/employees` | List all active employees |
| GET | `/api/employees/:id` | Single employee |
| POST | `/api/employees` | Create employee |
| PUT | `/api/employees/:id` | Update employee |

**POST body:**
```json
{
  "employee_code": "EMP-002",
  "full_name": "Jane Doe",
  "email": "jane@deepocean.io",
  "department": "Engineering",
  "designation": "Developer",
  "sector": "Sector 09A"
}
```

### Attendance

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/attendance/check-in` | Record check-in |
| POST | `/api/attendance/check-out` | Record check-out |
| GET | `/api/attendance/today/:employee_id` | Today's record |
| GET | `/api/attendance/history/:employee_id` | Paginated history (`?limit=30&offset=0`) |
| GET | `/api/attendance/activity/:employee_id` | Recent activity logs (`?limit=10`) |

**POST /check-in body:**
```json
{
  "employee_id": 1,
  "zone": "Tech Hub South",
  "auth_method": "Biometric/NFC",
  "workstation": "WS-04B"
}
```

---

## Flutter integration

The Flutter app uses `lib/services/api_client.dart`.  
Change `baseUrl` in that file to match your environment:

| Environment | URL |
|-------------|-----|
| Android emulator | `http://10.0.2.2:3000` |
| iOS simulator | `http://localhost:3000` |
<!-- | Physical device | `http://<your-LAN-IP>:3000` | -->



