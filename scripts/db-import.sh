#!/bin/bash
# MongoDB Import Script for Social Casino Recommendation Lobby
# This script imports MongoDB collections from a backup

set -e

# Configuration
MONGO_HOST="${MONGO_HOST:-localhost}"
MONGO_PORT="${MONGO_PORT:-27017}"
MONGO_USER="${MONGO_USER:-admin}"
MONGO_PASSWORD="${MONGO_PASSWORD:-admin_secret}"
MONGO_AUTH_DB="${MONGO_AUTH_DB:-admin}"
MONGO_DB="${MONGO_DB:-casino_cms}"
IMPORT_DIR="${IMPORT_DIR:-./exports/mongodb}"

echo "==================================="
echo "MongoDB Import Script"
echo "==================================="

# Check for import path argument or use latest
if [ -n "$1" ]; then
    IMPORT_PATH="$1"
elif [ -L "${IMPORT_DIR}/latest" ]; then
    IMPORT_PATH="${IMPORT_DIR}/$(readlink ${IMPORT_DIR}/latest)"
else
    echo "Usage: $0 <import_path>"
    echo ""
    echo "Available exports:"
    ls -la "${IMPORT_DIR}/" 2>/dev/null || echo "  No exports found in ${IMPORT_DIR}/"
    exit 1
fi

echo "Host: ${MONGO_HOST}:${MONGO_PORT}"
echo "Database: ${MONGO_DB}"
echo "Import Path: ${IMPORT_PATH}"
echo ""

# Verify import path exists
if [ ! -d "${IMPORT_PATH}" ]; then
    echo "Error: Import path not found: ${IMPORT_PATH}"
    exit 1
fi

# Check if running via Docker
if docker ps | grep -q casino-mongodb; then
    echo "Running import via Docker container..."
    
    # Find the database folder in the export
    DB_FOLDER="${IMPORT_PATH}/${MONGO_DB}"
    if [ ! -d "${DB_FOLDER}" ]; then
        # Try direct path
        DB_FOLDER="${IMPORT_PATH}"
    fi
    
    echo "Importing from: ${DB_FOLDER}"
    
    # Copy to container
    docker exec casino-mongodb mkdir -p /tmp/import
    docker cp "${DB_FOLDER}" casino-mongodb:/tmp/import/
    
    # Get the folder name that was copied
    FOLDER_NAME=$(basename "${DB_FOLDER}")
    
    # Run mongorestore
    docker exec casino-mongodb mongorestore \
        --uri="mongodb://${MONGO_USER}:${MONGO_PASSWORD}@localhost:27017/${MONGO_DB}?authSource=${MONGO_AUTH_DB}" \
        --drop \
        /tmp/import/${FOLDER_NAME}
    
    # Clean up
    docker exec casino-mongodb rm -rf /tmp/import
    
    echo ""
    echo "Import completed successfully!"
    
    # Show imported data counts
    echo ""
    echo "Imported data counts:"
    docker exec casino-mongodb mongosh --quiet -u ${MONGO_USER} -p ${MONGO_PASSWORD} --authenticationDatabase ${MONGO_AUTH_DB} ${MONGO_DB} --eval "
print('games: ' + db.games.countDocuments());
print('promotions: ' + db.promotions.countDocuments());
print('lobby-layouts: ' + db['lobby-layouts'].countDocuments());
print('media: ' + db.media.countDocuments());
print('users: ' + db.users.countDocuments());
"
else
    echo "Error: casino-mongodb container is not running"
    echo "Please start the stack with: docker compose up -d"
    exit 1
fi
