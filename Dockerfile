FROM quay.io/keycloak/keycloak:26.5.2

# Copy custom theme
COPY themes/mytheme /opt/keycloak/themes/mytheme

# Copy configuration
COPY conf/keycloak.conf /opt/keycloak/conf/keycloak.conf

# Copy entrypoint script
COPY docker-entrypoint.sh /opt/keycloak/docker-entrypoint.sh

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080

# Make script executable and run with shell
ENTRYPOINT ["/bin/sh", "/opt/keycloak/docker-entrypoint.sh"]
