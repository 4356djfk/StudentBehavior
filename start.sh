#!/usr/bin/env bash
set -e

echo "============================================"
echo "  Student Behavior Demo - Docker Deploy"
echo "============================================"
echo ""
echo "[1/2] Building and starting containers..."
docker compose up -d --build
echo ""
echo "[2/2] Waiting for services to be ready..."
sleep 5
echo ""
echo "============================================"
echo "  Deployment complete!"
echo ""
echo "  Frontend: http://localhost"
echo "  Backend:  http://localhost:8000"
echo "  API Docs: http://localhost:8000/scalar"
echo ""
echo "  Login credentials:"
echo "    Username: demo_admin"
echo "    Password: demo_only"
echo ""
echo "  Run \"docker compose down\" to stop."
echo "============================================"
