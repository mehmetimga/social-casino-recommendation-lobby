# Database Seed Data

This directory contains MongoDB data exported as JSON files for easy setup on new machines.

## Contents

| File | Description | Count |
|------|-------------|-------|
| `games.json` | All casino games | 143 |
| `promotions.json` | Active promotions | 15 |
| `lobby-layouts.json` | Lobby configurations | 2 |
| `media.json` | Uploaded media references | 163 |
| `users.json` | Admin user account | 1 |

## On a New Machine

1. Start the Docker services:
   ```bash
   docker compose up -d
   ```

2. Wait for MongoDB to be ready, then import:
   ```bash
   ./db-seed-data/import.sh
   ```

3. Access the app:
   - Frontend: http://localhost:5173
   - CMS Admin: http://localhost:3001/admin
   - Credentials: `admin@example.com` / `admin123`

## Updating Seed Data

After making changes in the CMS, export the current state:

```bash
./db-seed-data/export.sh
git add db-seed-data/
git commit -m "Update database seed data"
git push
```

## Note

The game images are stored separately in `casino-images/` and `casino-banners/` directories, which are also tracked in git.
