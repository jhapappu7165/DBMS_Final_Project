#!/bin/bash
# Cleanup script for Electronics Vendor Database System
# Stops all services: MySQL container, Flask backend, and related processes

echo "=== Electronics Vendor System Cleanup ==="
echo ""

# Stop MySQL container (but keep it - data persists)
echo "Stopping MySQL container..."
docker stop electronics-mysql 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ MySQL container stopped (data preserved)"
else
    echo "  (MySQL container was not running)"
fi

# Kill Flask processes on port 5000
echo ""
echo "Stopping Flask backend server..."
# Try multiple methods to find and kill processes on port 5000
FLASK_PID=$(lsof -ti:5000 2>/dev/null)
if [ ! -z "$FLASK_PID" ]; then
    kill -9 $FLASK_PID 2>/dev/null
    echo "✓ Flask server stopped (PID: $FLASK_PID)"
else
    # Try using fuser if lsof not available
    fuser -k 5000/tcp 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Flask server stopped (using fuser)"
    else
        echo "  (No Flask server running on port 5000)"
    fi
fi

# Kill any Python processes running backend.py
echo ""
echo "Stopping Python backend processes..."
pkill -9 -f "backend.py" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Python backend processes stopped"
else
    echo "  (No Python backend processes found)"
fi

# Also kill any python/flask processes on port 5000
pkill -9 -f "flask" 2>/dev/null

echo ""
echo "=== Cleanup Complete ==="
echo ""
echo "To start again:"
echo "  1. Start MySQL: docker start electronics-mysql"
echo "  2. Start UI: cd UI && python backend.py"
echo ""
echo "Note: Database and data are preserved. To completely reset:"
echo "  docker stop electronics-mysql && docker rm electronics-mysql"
echo "  docker run --name electronics-mysql -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_DATABASE=electronics_vendor -p 3306:3306 -d mysql:8.0"
echo "  docker exec -i electronics-mysql mysql -uroot -prootpass < database/Phase1_Schm.sql"
echo "  docker exec -i electronics-mysql mysql -uroot -prootpass < database/Phase2_DataPopulation.sql"