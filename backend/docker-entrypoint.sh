#!/bin/sh
set -eu

until python - <<'PY'
import os
from sqlalchemy import create_engine, text

url = os.environ.get('DATABASE_URL')
if not url:
    raise SystemExit(1)

try:
    engine = create_engine(url, pool_pre_ping=True)
    with engine.connect() as conn:
        conn.execute(text('SELECT 1'))
    raise SystemExit(0)
except Exception:
    raise SystemExit(1)
PY
 do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

alembic upgrade head
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
