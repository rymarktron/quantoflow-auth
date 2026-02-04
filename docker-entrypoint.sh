#!/bin/bash
set -e

# Export environment variables so they're available to Keycloak
export DB_USERNAME=${DB_USERNAME:-postgres}
export DB_PASSWORD=${DB_PASSWORD}
export DB_HOST=${DB_HOST}
export DB_PORT=${DB_PORT:-5432}
export DB_NAME=${DB_NAME:-keycloak}

# Run Keycloak
exec /opt/keycloak/bin/kc.sh start
