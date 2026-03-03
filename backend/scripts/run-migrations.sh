#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/../migrations"
DB_NAME="meridien_dev"

echo "📦 Running database migrations..."

# Check if database exists
DB_EXISTS=$(sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -w "$DB_NAME")
if [ -z "$DB_EXISTS" ]; then
    echo "❌ Database '$DB_NAME' does not exist. Please run ./scripts/create-database.sh first"
    exit 1
fi

# Ensure schema_migrations tracking table exists
sudo -u postgres psql -d "$DB_NAME" -c "
    CREATE TABLE IF NOT EXISTS schema_migrations (
        version VARCHAR(255) PRIMARY KEY,
        applied_at TIMESTAMP NOT NULL DEFAULT NOW()
    );
" > /dev/null

# Collect migration files into an array (handles spaces in path correctly)
mapfile -t MIGRATION_FILES < <(find "$MIGRATIONS_DIR" -maxdepth 1 -name '*.up.sql' | sort)

if [ "${#MIGRATION_FILES[@]}" -eq 0 ]; then
    echo "⚠️  No migration files found in $MIGRATIONS_DIR"
    exit 0
fi

APPLIED=0
SKIPPED=0

for MIGRATION_FILE in "${MIGRATION_FILES[@]}"; do
    FILENAME=$(basename "$MIGRATION_FILE")
    VERSION="${FILENAME%.up.sql}"

    # Check if already applied
    ALREADY_APPLIED=$(sudo -u postgres psql -d "$DB_NAME" -tAc \
        "SELECT 1 FROM schema_migrations WHERE version = '$VERSION';")

    if [ "$ALREADY_APPLIED" = "1" ]; then
        echo "  ⏭  Skipping $FILENAME (already applied)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    echo "  ⬆️  Applying $FILENAME..."
    PSQL_OUT=$(sudo -u postgres psql -d "$DB_NAME" < "$MIGRATION_FILE" 2>&1)
    PSQL_EXIT=$?
    echo "$PSQL_OUT"

    # Detect transaction rollback (psql exits 0 even on ROLLBACK)
    if [ $PSQL_EXIT -ne 0 ] || echo "$PSQL_OUT" | grep -q "^ROLLBACK$"; then
        echo "  ❌ Failed to apply $FILENAME (transaction rolled back)"
        exit 1
    fi

    sudo -u postgres psql -d "$DB_NAME" -c \
        "INSERT INTO schema_migrations (version) VALUES ('$VERSION');" > /dev/null
    echo "  ✅ $FILENAME applied"
    APPLIED=$((APPLIED + 1))
done

echo ""
echo "✅ Migrations complete — $APPLIED applied, $SKIPPED skipped."
