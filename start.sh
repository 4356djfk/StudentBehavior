#!/usr/bin/env bash
set -e

RED='\033[0;31m'
NC='\033[0m'

check_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}[ERROR] Docker not found. Please install Docker first.${NC}"
        exit 1
    fi
    if ! docker info &>/dev/null; then
        echo -e "${RED}[ERROR] Docker daemon not running. Please start Docker.${NC}"
        exit 1
    fi
    if ! docker compose version &>/dev/null; then
        echo -e "${RED}[ERROR] docker compose plugin not available.${NC}"
        exit 1
    fi
}

wait_for_service() {
    local url=$1
    local max=${2:-60}
    local count=0
    while [ $count -lt $max ]; do
        if curl -sf --max-time 2 "$url" >/dev/null 2>&1; then
            return 0
        fi
        printf "."
        sleep 2
        count=$((count + 1))
    done
    echo ""
    return 1
}

show_info() {
    echo ""
    echo "============================================"
    echo "  Deployment Complete!"
    echo "============================================"
    echo ""
    echo "  Frontend : http://localhost"
    echo "  Backend  : http://localhost:8000"
    echo "  API Docs : http://localhost:8000/scalar"
    echo ""
    echo "  Login credentials:"
    echo "    Username: demo_admin"
    echo "    Password: demo_only"
    echo ""
    echo "  Run option [2] to stop all containers."
    echo "============================================"
}

deploy() {
    echo ""
    echo "[1/3] Stopping existing containers..."
    docker compose down 2>/dev/null
    echo ""
    echo "[2/3] Building and starting containers..."
    docker compose up -d --build
    echo ""
    echo "[3/3] Waiting for services to be ready..."
    if wait_for_service "http://localhost:8000/scalar" 60; then
        show_info
    else
        echo -e "${RED}[WARN] Backend may still be starting. Check logs with option [4].${NC}"
    fi
}

stop() {
    echo ""
    echo "Stopping all containers..."
    docker compose down
    echo "Done."
}

restart() {
    echo ""
    echo "Restarting all containers..."
    docker compose restart || {
        echo -e "${RED}[WARN] restart failed, trying full rebuild...${NC}"
        deploy
    }
    echo "Done."
}

logs() {
    echo ""
    echo "Showing logs (Ctrl+C to exit)..."
    docker compose logs -f
}

status() {
    echo ""
    docker compose ps
    echo ""
    docker stats --no-stream
}

menu() {
    echo ""
    echo "============================================"
    echo "  Student Behavior Demo - Docker Deploy"
    echo "============================================"
    echo ""
    echo "  [1] Deploy / Start"
    echo "  [2] Stop"
    echo "  [3] Restart"
    echo "  [4] View Logs"
    echo "  [5] Status"
    echo "  [6] Exit"
    echo ""
    read -p "  Enter option [1-6]: " choice

    case $choice in
        1) deploy ;;
        2) stop ;;
        3) restart ;;
        4) logs ;;
        5) status ;;
        6) exit 0 ;;
    esac

    menu
}

# === Entry ===
check_docker
echo ""
echo "Docker environment OK."
menu
