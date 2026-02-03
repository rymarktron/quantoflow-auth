# GCP Cloud Run Canada Deployment Guide

## Overview
Deploy Keycloak to Google Cloud Run in Montreal, Canada (northamerica-northeast1 region)

## Prerequisites
- GCP Account with billing enabled
- GCP Project created
- `gcloud` CLI installed
- Docker installed (for local testing)
- Database credentials ready

## Quick Deploy (One Command)

```bash
# Set your credentials
export DB_PASSWORD="your_secure_password"
export DB_HOST="canadian-database.ch6qo8ksw80r.ca-central-1.rds.amazonaws.com"

# Run deployment script
./deploy-gcp-canada.sh YOUR_GCP_PROJECT_ID
```

## Step-by-Step Manual Deployment

### 1. Setup GCP Project
```bash
# Set project
gcloud config set project YOUR_GCP_PROJECT_ID

# Enable APIs
gcloud services enable \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  --quiet
```

### 2. Create Artifact Registry (Montreal)
```bash
gcloud artifacts repositories create quantoflow \
  --repository-format=docker \
  --location=northamerica-northeast1 \
  --description="Quantoflow Keycloak - Canada"

# Configure Docker auth
gcloud auth configure-docker northamerica-northeast1-docker.pkg.dev
```

### 3. Build & Push Image
```bash
gcloud builds submit \
  --tag northamerica-northeast1-docker.pkg.dev/YOUR_PROJECT/quantoflow/keycloak:latest \
  --region northamerica-northeast1 \
  --machine-type N1_HIGHCPU_8
```

### 4. Deploy to Cloud Run (Canada)
```bash
gcloud run deploy quantoflow-auth \
  --image northamerica-northeast1-docker.pkg.dev/YOUR_PROJECT/quantoflow/keycloak:latest \
  --platform managed \
  --region northamerica-northeast1 \
  --memory 2Gi \
  --cpu 2 \
  --timeout 3600 \
  --max-instances 10 \
  --allow-unauthenticated \
  --set-env-vars \
    DB_USERNAME=postgres,\
    DB_PASSWORD=YOUR_PASSWORD,\
    DB_HOST=canadian-database.ch6qo8ksw80r.ca-central-1.rds.amazonaws.com,\
    DB_PORT=5432,\
    DB_NAME=keycloak
```

## View Deployment Status

### Get Service URL
```bash
gcloud run services describe quantoflow-auth \
  --region northamerica-northeast1 \
  --format 'value(status.url)'
```

### View Logs
```bash
# Real-time logs
gcloud run logs read quantoflow-auth \
  --region northamerica-northeast1 \
  --follow

# Last 50 lines
gcloud run logs read quantoflow-auth \
  --region northamerica-northeast1 \
  --limit 50
```

### Check Service Details
```bash
gcloud run services describe quantoflow-auth \
  --region northamerica-northeast1
```

### Monitor Revisions
```bash
gcloud run revisions list \
  --service quantoflow-auth \
  --region northamerica-northeast1
```

## Custom Domain Setup

### Option A: Add Custom Domain
```bash
# Create domain mapping
gcloud run domain-mappings create \
  --service quantoflow-auth \
  --domain auth.yourdomain.com \
  --region northamerica-northeast1

# Get DNS info
gcloud run domain-mappings describe auth.yourdomain.com

# At your domain registrar, create CNAME:
# Name: auth
# Target: ghs.googlehosted.com
```

### Option B: Load Balancer with SSL
```bash
# Create SSL certificate
gcloud compute ssl-certificates create quantoflow-ssl \
  --domains auth.yourdomain.com

# Create load balancer backend
gcloud compute backend-services create quantoflow-backend \
  --global \
  --protocol HTTP2 \
  --health-checks health-check-name
```

## Monitor & Troubleshoot

### Check Health
```bash
# Verify service is running
curl https://YOUR_SERVICE_URL/health

# Check Keycloak is responsive
curl -I https://YOUR_SERVICE_URL/admin
```

### View Error Logs
```bash
gcloud run logs read quantoflow-auth \
  --region northamerica-northeast1 \
  --filter "severity>=ERROR" \
  --limit 20
```

### Scale Settings
```bash
# Update max instances
gcloud run services update quantoflow-auth \
  --max-instances 20 \
  --region northamerica-northeast1

# Update memory
gcloud run services update quantoflow-auth \
  --memory 4Gi \
  --region northamerica-northeast1
```

## Network & Security

### Add VPC Connector (Optional)
```bash
# Create VPC connector for private RDS access
gcloud compute networks vpc-access connectors create quantoflow-connector \
  --network default \
  --range 10.8.0.0/28 \
  --region northamerica-northeast1

# Update service to use connector
gcloud run services update quantoflow-auth \
  --vpc-connector quantoflow-connector \
  --region northamerica-northeast1
```

### Restrict Access
```bash
# Internal only (no public access)
gcloud run services update quantoflow-auth \
  --ingress internal-only \
  --region northamerica-northeast1

# Allow all
gcloud run services update quantoflow-auth \
  --ingress all \
  --region northamerica-northeast1
```

## Cost Optimization

**Estimated Monthly Cost:**
- Cloud Run compute: $40-80 (variable based on traffic)
- Artifact Registry storage: ~$5
- RDS PostgreSQL: $50-80
- **Total: ~$95-165/month**

**Reduce costs:**
- Reduce memory to 1Gi if sufficient
- Lower CPU to 1 vCPU
- Set `--max-instances 2` to limit scaling
- Use Cloud Tasks for async operations

## Troubleshooting

### Service won't start
```bash
# Check logs for errors
gcloud run logs read quantoflow-auth \
  --region northamerica-northeast1 \
  --limit 100 | grep ERROR

# Verify environment variables
gcloud run services describe quantoflow-auth \
  --region northamerica-northeast1 \
  --format yaml | grep -A 20 "env:"
```

### Database connection issues
```bash
# Verify RDS security group allows Cloud Run IP
# Check VPC connector is properly configured
# Verify DB credentials in env vars

# Test connectivity
gcloud run services update quantoflow-auth \
  --update-env-vars TEST_DB=true \
  --region northamerica-northeast1
```

### High latency
- Check service instance count
- Monitor Cloud Run metrics in GCP Console
- Consider adding Cloud CDN for static assets
- Scale up CPU/memory if needed

## Updating Deployment

### Deploy new version
```bash
# Make code changes
git add .
git commit -m "Update theme"
git push

# Redeploy
gcloud builds submit \
  --tag northamerica-northeast1-docker.pkg.dev/YOUR_PROJECT/quantoflow/keycloak:latest \
  --region northamerica-northeast1

# Cloud Run auto-creates new revision
```

### Rollback to previous version
```bash
# List revisions
gcloud run revisions list \
  --service quantoflow-auth \
  --region northamerica-northeast1

# Route traffic to previous revision
gcloud run services update-traffic quantoflow-auth \
  --to-revisions REVISION_NAME=100 \
  --region northamerica-northeast1
```

## Useful Links

- [GCP Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Keycloak on Cloud Run](https://www.keycloak.org/docs/latest/deployment_guide/)
- [GCP Regions & Zones](https://cloud.google.com/compute/docs/regions-zones)
- [Cloud Run Quotas](https://cloud.google.com/run/quotas)
- [Pricing Calculator](https://cloud.google.com/products/calculator)

## Support

For issues:
1. Check logs: `gcloud run logs read quantoflow-auth --region northamerica-northeast1`
2. Review [troubleshooting guide](#troubleshooting)
3. Check [Keycloak docs](https://www.keycloak.org/docs/)
4. Review [GCP documentation](https://cloud.google.com/run/docs)
