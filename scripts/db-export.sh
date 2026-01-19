#!/bin/bash
# MongoDB Export Script for Social Casino Recommendation Lobby
# This script exports all MongoDB collections for backup/migration

set -e

# Configuration
MONGO_HOST="${MONGO_HOST:-localhost}"
MONGO_PORT="${MONGO_PORT:-27017}"
MONGO_USER="${MONGO_USER:-admin}"
MONGO_PASSWORD="${MONGO_PASSWORD:-admin_secret}"
MONGO_AUTH_DB="${MONGO_AUTH_DB:-admin}"
MONGO_DB="${MONGO_DB:-casino_cms}"
EXPORT_DIR="${EXPORT_DIR:-./exports/mongodb}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EXPORT_PATH="${EXPORT_DIR}/${TIMESTAMP}"

echo "==================================="
echo "MongoDB Export Script"
echo "==================================="
echo "Host: ${MONGO_HOST}:${MONGO_PORT}"
echo "Database: ${MONGO_DB}"
echo "Export Path: ${EXPORT_PATH}"
echo ""

# Create export directory
mkdir -p "${EXPORT_PATH}"

# Check if running inside Docker or on host
if [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    # Inside Docker - use localhost
    MONGO_URI="mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:27017/${MONGO_DB}?authSource=${MONGO_AUTH_DB}"
else
    # On host - check if container is running
    if docker ps | grep -q casino-mongodb; then
        echo "Running export via Docker container..."
        
        # Export using docker exec
        docker exec casino-mongodb mongodump \
            --uri="mongodb://${MONGO_USER}:${MONGO_PASSWORD}@localhost:27017/${MONGO_DB}?authSource=${MONGO_AUTH_DB}" \
            --out=/tmp/dump
        
        # Copy from container
        docker cp casino-mongodb:/tmp/dump/${MONGO_DB} "${EXPORT_PATH}/"
        
        # Clean up
        docker exec casino-mongodb rm -rf /tmp/dump
        
        echo ""
        echo "Export completed successfully!"
        echo "Exported to: ${EXPORT_PATH}/${MONGO_DB}"
        
        # Create a latest symlink
        rm -f "${EXPORT_DIR}/latest"
        ln -s "${TIMESTAMP}" "${EXPORT_DIR}/latest"
        
        # Show exported files
        echo ""
        echo "Exported collections:"
        ls -la "${EXPORT_PATH}/${MONGO_DB}/"
        
        # Create metadata file
        cat > "${EXPORT_PATH}/metadata.json" << EOF
{
  "exportDate": "$(date -Iseconds)",
  "database": "${MONGO_DB}",
  "collections": $(docker exec casino-mongodb mongosh --quiet -u ${MONGO_USER} -p ${MONGO_PASSWORD} --authenticationDatabase ${MONGO_AUTH_DB} ${MONGO_DB} --eval "JSON.stringify(db.getCollectionNames())"),
  "stats": {
    "games": $(docker exec casino-mongodb mongosh --quiet -u ${MONGO_USER} -p ${MONGO_PASSWORD} --authenticationDatabase ${MONGO_AUTH_DB} ${MONGO_DB} --eval "db.games.countDocuments()"),
    "promotions": $(docker exec casino-mongodb mongosh --quiet -u ${MONGO_USER} -p ${MONGO_PASSWORD} --authenticationDatabase ${MONGO_AUTH_DB} ${MONGO_DB} --eval "db.promotions.countDocuments()"),
    "lobbyLayouts": $(docker exec casino-mongodb mongosh --quiet -u ${MONGO_USER} -p ${MONGO_PASSWORD} --authenticationDatabase ${MONGO_AUTH_DB} ${MONGO_DB} --eval "db['lobby-layouts'].countDocuments()"),
    "media": $(docker exec casino-mongodb mongosh --quiet -u ${MONGO_USER} -p ${MONGO_PASSWORD} --authenticationDatabase ${MONGO_AUTH_DB} ${MONGO_DB} --eval "db.media.countDocuments()"),
    "users": $(docker exec casino-mongodb mongosh --quiet -u ${MONGO_USER} -p ${MONGO_PASSWORD} --authenticationDatabase ${MONGO_AUTH_DB} ${MONGO_DB} --eval "db.users.countDocuments()")
  }
}
EOF
        echo ""
        echo "Metadata saved to: ${EXPORT_PATH}/metadata.json"
        cat "${EXPORT_PATH}/metadata.json"
        
        exit 0
    else
        echo "Error: casino-mongodb container is not running"
        echo "Please start the stack with: docker compose up -d"
        exit 1
    fi
fi
