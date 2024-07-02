#!/bin/bash

# Ensure this script is executable
if [ ! -x "$0" ]; then
  chmod +x "$0"
fi

# Make wait-for-it.sh executable
chmod +x /usr/local/bin/wait-for-it.sh

# Ensure the database is ready before starting the backend
/usr/local/bin/wait-for-it.sh db:1433 -- echo "Database is up"

# Initialize the database
/opt/mssql-tools/bin/sqlcmd -S db -U SA -P "$DB_PASSWORD" -i /path/to/init-db.sql

# Start the backend
cd /workspace/backend
python app.py &

# Start the frontend
cd /workspace/frontend
npm start
