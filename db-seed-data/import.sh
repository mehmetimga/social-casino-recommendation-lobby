#!/bin/bash
# Import MongoDB seed data from JSON files
# Run this on a new machine after starting Docker services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==================================="
echo "MongoDB Import from JSON"
echo "==================================="

# Check if MongoDB container is running
if ! docker ps | grep -q casino-mongodb; then
    echo "Error: casino-mongodb container is not running"
    echo "Please start the stack first: docker compose up -d"
    exit 1
fi

echo "Copying JSON files to container..."
docker cp "${SCRIPT_DIR}/games.json" casino-mongodb:/tmp/
docker cp "${SCRIPT_DIR}/promotions.json" casino-mongodb:/tmp/
docker cp "${SCRIPT_DIR}/lobby-layouts.json" casino-mongodb:/tmp/
docker cp "${SCRIPT_DIR}/media.json" casino-mongodb:/tmp/
docker cp "${SCRIPT_DIR}/users.json" casino-mongodb:/tmp/

echo ""
echo "Importing collections..."

# Import each collection (--drop removes existing data first)
echo "  → Importing games..."
docker exec casino-mongodb mongoimport \
    --uri="mongodb://admin:admin_secret@localhost:27017/casino_cms?authSource=admin" \
    --collection=games --file=/tmp/games.json --jsonArray --drop

echo "  → Importing promotions..."
docker exec casino-mongodb mongoimport \
    --uri="mongodb://admin:admin_secret@localhost:27017/casino_cms?authSource=admin" \
    --collection=promotions --file=/tmp/promotions.json --jsonArray --drop

echo "  → Importing lobby-layouts..."
docker exec casino-mongodb mongoimport \
    --uri="mongodb://admin:admin_secret@localhost:27017/casino_cms?authSource=admin" \
    --collection=lobby-layouts --file=/tmp/lobby-layouts.json --jsonArray --drop

echo "  → Importing media..."
docker exec casino-mongodb mongoimport \
    --uri="mongodb://admin:admin_secret@localhost:27017/casino_cms?authSource=admin" \
    --collection=media --file=/tmp/media.json --jsonArray --drop

echo "  → Importing users..."
docker exec casino-mongodb mongoimport \
    --uri="mongodb://admin:admin_secret@localhost:27017/casino_cms?authSource=admin" \
    --collection=users --file=/tmp/users.json --jsonArray --drop

# Clean up temp files
docker exec casino-mongodb rm -f /tmp/games.json /tmp/promotions.json /tmp/lobby-layouts.json /tmp/media.json /tmp/users.json

echo ""
echo "==================================="
echo "✅ Import Complete!"
echo "==================================="
echo ""
echo "Imported data counts:"
docker exec casino-mongodb mongosh --quiet -u admin -p admin_secret --authenticationDatabase admin casino_cms --eval "
print('  games: ' + db.games.countDocuments());
print('  promotions: ' + db.promotions.countDocuments());
print('  lobby-layouts: ' + db['lobby-layouts'].countDocuments());
print('  media: ' + db.media.countDocuments());
print('  users: ' + db.users.countDocuments());
"
