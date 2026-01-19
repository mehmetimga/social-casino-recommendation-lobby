#!/bin/bash
# Export MongoDB data to JSON files (for committing to git)
# Run this to update the seed data with current database state

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==================================="
echo "MongoDB Export to JSON"
echo "==================================="

# Check if MongoDB container is running
if ! docker ps | grep -q casino-mongodb; then
    echo "Error: casino-mongodb container is not running"
    echo "Please start the stack first: docker compose up -d"
    exit 1
fi

echo "Exporting collections to JSON..."

docker exec casino-mongodb mongoexport \
    --uri="mongodb://admin:admin_secret@localhost:27017/casino_cms?authSource=admin" \
    --collection=games --out=/tmp/games.json --jsonArray
docker cp casino-mongodb:/tmp/games.json "${SCRIPT_DIR}/"
echo "  ✓ games.json"

docker exec casino-mongodb mongoexport \
    --uri="mongodb://admin:admin_secret@localhost:27017/casino_cms?authSource=admin" \
    --collection=promotions --out=/tmp/promotions.json --jsonArray
docker cp casino-mongodb:/tmp/promotions.json "${SCRIPT_DIR}/"
echo "  ✓ promotions.json"

docker exec casino-mongodb mongoexport \
    --uri="mongodb://admin:admin_secret@localhost:27017/casino_cms?authSource=admin" \
    --collection=lobby-layouts --out=/tmp/lobby-layouts.json --jsonArray
docker cp casino-mongodb:/tmp/lobby-layouts.json "${SCRIPT_DIR}/"
echo "  ✓ lobby-layouts.json"

docker exec casino-mongodb mongoexport \
    --uri="mongodb://admin:admin_secret@localhost:27017/casino_cms?authSource=admin" \
    --collection=media --out=/tmp/media.json --jsonArray
docker cp casino-mongodb:/tmp/media.json "${SCRIPT_DIR}/"
echo "  ✓ media.json"

docker exec casino-mongodb mongoexport \
    --uri="mongodb://admin:admin_secret@localhost:27017/casino_cms?authSource=admin" \
    --collection=users --out=/tmp/users.json --jsonArray
docker cp casino-mongodb:/tmp/users.json "${SCRIPT_DIR}/"
echo "  ✓ users.json"

# Clean up temp files
docker exec casino-mongodb rm -f /tmp/games.json /tmp/promotions.json /tmp/lobby-layouts.json /tmp/media.json /tmp/users.json

echo ""
echo "==================================="
echo "✅ Export Complete!"
echo "==================================="
echo ""
echo "Files updated in: ${SCRIPT_DIR}/"
ls -la "${SCRIPT_DIR}"/*.json
echo ""
echo "You can now commit these files to git:"
echo "  git add db-seed-data/"
echo "  git commit -m 'Update database seed data'"
