#!/bin/bash
# Setup Script for Social Casino Recommendation Lobby
# Run this script on a new machine to set up the project

set -e

echo "==================================="
echo "Social Casino Setup Script"
echo "==================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop first."
    exit 1
fi
echo "✅ Docker is installed"

# Check Docker Compose
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please update Docker."
    exit 1
fi
echo "✅ Docker Compose is available"

# Check if Ollama is installed (optional)
if command -v ollama &> /dev/null; then
    echo "✅ Ollama is installed (optional - for AI features)"
else
    echo "⚠️  Ollama not installed (optional - AI features will use fallbacks)"
fi

echo ""
echo "Step 1: Starting infrastructure services..."
docker compose up -d postgres mongodb qdrant

echo ""
echo "Waiting for databases to be healthy..."
sleep 10

# Wait for MongoDB to be healthy
MAX_RETRIES=30
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if docker exec casino-mongodb mongosh --quiet -u admin -p admin_secret --authenticationDatabase admin --eval "db.runCommand('ping').ok" 2>/dev/null | grep -q 1; then
        echo "✅ MongoDB is ready"
        break
    fi
    RETRY=$((RETRY + 1))
    echo "Waiting for MongoDB... ($RETRY/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "❌ MongoDB failed to start"
    exit 1
fi

# Wait for PostgreSQL
RETRY=0
while [ $RETRY -lt $MAX_RETRIES ]; do
    if docker exec casino-postgres pg_isready -U casino -d casino_db 2>/dev/null; then
        echo "✅ PostgreSQL is ready"
        break
    fi
    RETRY=$((RETRY + 1))
    echo "Waiting for PostgreSQL... ($RETRY/$MAX_RETRIES)"
    sleep 2
done

echo ""
echo "Step 2: Starting all services..."
docker compose up -d --build

echo ""
echo "Waiting for services to start..."
sleep 15

echo ""
echo "Step 3: Checking for existing database export..."

EXPORT_DIR="./exports/mongodb"
if [ -d "${EXPORT_DIR}/latest" ] || [ -L "${EXPORT_DIR}/latest" ]; then
    echo "Found existing database export. Would you like to import it? (y/n)"
    read -r IMPORT_CHOICE
    if [ "$IMPORT_CHOICE" = "y" ] || [ "$IMPORT_CHOICE" = "Y" ]; then
        echo "Importing database..."
        ./scripts/db-import.sh
    fi
else
    echo "No existing export found."
    echo ""
    echo "Step 4: Running seed to populate database..."
    
    # Run seed via the CMS container
    docker exec casino-cms pnpm tsx seed.ts || {
        echo "⚠️  Seed failed or already run. Checking data..."
    }
fi

echo ""
echo "Step 5: Verifying setup..."

# Check all services
echo ""
echo "Service Status:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep casino

echo ""
echo "Data counts:"
docker exec casino-mongodb mongosh --quiet -u admin -p admin_secret --authenticationDatabase admin casino_cms --eval "
print('games: ' + db.games.countDocuments());
print('promotions: ' + db.promotions.countDocuments());
print('lobby-layouts: ' + db['lobby-layouts'].countDocuments());
print('media: ' + db.media.countDocuments());
"

echo ""
echo "==================================="
echo "✅ Setup Complete!"
echo "==================================="
echo ""
echo "Access the application at:"
echo "  • Frontend:    http://localhost:5173"
echo "  • CMS Admin:   http://localhost:3001/admin"
echo "  • ML API Docs: http://localhost:8083/docs"
echo ""
echo "Default CMS credentials (if seeded):"
echo "  • Email:    admin@example.com"
echo "  • Password: admin123"
echo ""
echo "To stop all services:  docker compose down"
echo "To view logs:          docker compose logs -f"
echo ""
