#!/bin/bash
set -e

# Start frontend first (no external npm deps, starts immediately)
cd /app/frontend
node server.js &

# Install backend dependencies and start
cd /app/backend
pip install -r requirements.txt
python3 main.py &
