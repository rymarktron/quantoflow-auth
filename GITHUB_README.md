# Quantoflow Keycloak

A custom Keycloak 26.5.2 deployment with the Quantoflow branded theme, connected to AWS RDS PostgreSQL, ready for GCP deployment.

## Features

✨ **Custom Quantoflow Theme**
- Custom branded login page with Quantoflow logo
- Green wave animations at the bottom
- Fully responsive design (mobile, tablet, desktop)
- Professional styling with rounded borders and shadows
- Privacy & Documentation links in footer

🗄️ **Database**
- PostgreSQL 17 on AWS RDS
- Separate `keycloak` database
- Environment-based configuration
- Secure credential management

🚀 **Deployment Ready**
- Environment variables for all sensitive data
- `.env.example` template for easy setup
- `.gitignore` to protect secrets
- Ready for Docker containerization
- GCP deployment compatible

## Project Structure

```
keycloak-26.5.2/
├── bin/                          # Keycloak scripts (kc.sh, kc.bat, etc)
├── conf/
│   ├── keycloak.conf            # Main configuration (uses env vars)
│   └── cache-ispn.xml           # Infinispan cache config
├── themes/
│   └── mytheme/                 # Custom Quantoflow theme
│       ├── theme.properties
│       ├── login/
│       │   ├── login.ftl        # Login page template
│       │   ├── theme.properties
│       │   └── resources/
│       │       ├── css/
│       │       │   └── login.css # Custom styling
│       │       └── img/
│       │           └── quantoflow-logo.png
│       └── README.md
├── lib/                          # Keycloak libraries
├── providers/                    # Custom providers directory
├── conf/keycloak.conf           # Configuration file
├── .env                         # Environment variables (DO NOT COMMIT)
├── .env.example                 # Environment template
├── .gitignore                   # Git ignore rules
└── README.md                    # This file
```

## Quick Start

### Prerequisites
- Java 21+
- PostgreSQL 13+ (AWS RDS or local)
- macOS/Linux (or WSL on Windows)

### 1. Setup Environment

Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` with your RDS credentials:
```bash
DB_USERNAME=postgres
DB_PASSWORD=your_secure_password
DB_HOST=your-rds-endpoint.ca-central-1.rds.amazonaws.com
DB_PORT=5432
DB_NAME=keycloak
```

### 2. Build Configuration

```bash
source .env
bin/kc.sh build
```

### 3. Start Server (Development)

```bash
source .env
bin/kc.sh start-dev
```

Server will be available at: `http://localhost:8080`

### 4. Access Admin Console

```
http://localhost:8080/admin
```

First login will prompt you to create an admin password.

## Configuration

### Database Settings
All database configuration uses environment variables for security:

```properties
# keycloak.conf
db=postgres
db-username=${DB_USERNAME}
db-password=${DB_PASSWORD}
db-url=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
```

### Theme Configuration
The Quantoflow theme is automatically set as the login theme. To verify:

1. Go to Admin Console → Realm Settings → Themes
2. Confirm "Login Theme" is set to `mytheme`
3. Refresh login page to see changes

### Custom Theme Files

**Login Page Template:** `themes/mytheme/login/login.ftl`
- FreeMarker template for login page HTML
- Includes footer links and form elements
- Responsive design support

**Styles:** `themes/mytheme/login/resources/css/login.css`
- Custom styling for login page
- Green color scheme (#4a9d6f primary, #2d7a52 dark)
- Wave animations and responsive media queries

**Assets:** `themes/mytheme/login/resources/img/`
- Quantoflow logo and other branding assets

## Deployment

### Docker Build

Create a `Dockerfile`:
```dockerfile
FROM quay.io/keycloak/keycloak:26.5.2

COPY themes/mytheme /opt/keycloak/themes/mytheme
COPY conf/keycloak.conf /opt/keycloak/conf/keycloak.conf

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start"]
```

Build and push to GCP Artifact Registry:
```bash
docker build -t gcr.io/your-project/keycloak:latest .
docker push gcr.io/your-project/keycloak:latest
```

### GCP Cloud Run Deployment

```bash
gcloud run deploy keycloak \
  --image gcr.io/your-project/keycloak:latest \
  --region us-central1 \
  --set-env-vars DB_VENDOR=postgres,DB_USERNAME=postgres,DB_PASSWORD=***,DB_HOST=your-rds-host,DB_PORT=5432,DB_NAME=keycloak \
  --memory 2Gi \
  --cpu 2
```

### GCP GKE Deployment

Use Helm chart or create deployment manifest:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: keycloak-config
data:
  keycloak.conf: |
    db=postgres
    db-username=${DB_USERNAME}
    db-password=${DB_PASSWORD}
    db-url=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: keycloak
        image: gcr.io/your-project/keycloak:latest
        env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        - name: DB_HOST
          value: "your-rds-endpoint"
```

## Database Setup

### Create Keycloak Database

Connect to your RDS PostgreSQL:
```bash
psql -h canadian-database.ch6qo8ksw80r.ca-central-1.rds.amazonaws.com \
     -U postgres \
     -d postgres
```

Create the keycloak database (Keycloak will initialize tables automatically):
```sql
CREATE DATABASE keycloak WITH ENCODING 'UTF8';
```

### Verify Connection

Check if tables were created after first Keycloak startup:
```bash
psql -h canadian-database.ch6qo8ksw80r.ca-central-1.rds.amazonaws.com \
     -U postgres \
     -d keycloak \
     -c "\dt"
```

## Theme Customization

### Modify Colors

Edit `themes/mytheme/login/resources/css/login.css`:
```css
/* Change primary green */
.btn-primary {
    background-color: #YOUR_COLOR;
}

/* Change wave colors */
.kc-waves svg path:nth-child(1) {
    fill: #YOUR_COLOR;
}
```

### Change Logo

Replace `themes/mytheme/login/resources/img/quantoflow-logo.png` with your logo.

### Customize Links

Edit `themes/mytheme/login/login.ftl` footer section:
```ftl
<li><a href="https://your-privacy-url.com" target="_blank">Privacy</a></li>
```

## Security Best Practices

✅ **Environment Variables**
- Store all credentials in `.env` (never commit)
- Use strong passwords
- Rotate credentials regularly

✅ **Database Security**
- Use VPC endpoint for RDS access
- Enable encryption at rest and in transit
- Restrict security groups to Keycloak only
- Use separate read replicas for backups

✅ **HTTPS/TLS**
- Always use HTTPS in production
- Use valid SSL certificates
- Set `proxy=reencrypt` if behind reverse proxy

✅ **Access Control**
- Change default admin password
- Use strong authentication policies
- Implement MFA for admin users
- Audit logs regularly

## Troubleshooting

### Database Connection Issues

Check logs:
```bash
grep -i "error\|failed\|connection" logs/keycloak.log
```

Verify RDS security group:
- Ensure PostgreSQL port (5432) is open to Keycloak instance
- Check VPC and subnet routing

### Theme Not Showing

1. Clear browser cache
2. Restart Keycloak: `Ctrl+C` and restart
3. Verify theme is in `themes/mytheme/`
4. Check Admin Console → Realm Settings → Themes

### Performance Issues

- Check database query logs
- Enable caching in `conf/cache-ispn.xml`
- Consider RDS instance size
- Use read replicas for scaling

## Documentation

- [Keycloak Server Documentation](https://www.keycloak.org/docs/latest/server_development/)
- [Keycloak Theme Development Guide](https://www.keycloak.org/docs/latest/server_development/#_themes)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [AWS RDS PostgreSQL Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)

## Support & Contributing

For issues with:
- **Quantoflow Theme**: Check `themes/mytheme/README.md`
- **Keycloak Core**: Refer to [official Keycloak documentation](https://www.keycloak.org/)
- **Database**: Review RDS and PostgreSQL documentation

## License

Keycloak is licensed under Apache 2.0. This custom theme and deployment configuration are provided as-is.

---

**Last Updated:** February 3, 2026
**Keycloak Version:** 26.5.2
**Theme Name:** mytheme (Quantoflow)
