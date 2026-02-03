#!/bin/bash

# Deploy Keycloak to Google Cloud Run (Canada - Montreal Region)
# Usage: ./deploy-gcp-canada.sh YOUR_GCP_PROJECT_ID

set -e

PROJECT_ID=${1:-}

if [ -z "$PROJECT_ID" ]; then
  echo "Usage: ./deploy-gcp-canada.sh YOUR_GCP_PROJECT_ID"
  echo "Example: ./deploy-gcp-canada.sh my-gcp-project"
  exit 1
fi

REGION="northamerica-northeast1"  # Montreal, Canada
SERVICE_NAME="quantoflow-auth"
IMAGE_NAME="quantoflow-keycloak"

echo "🚀 Deploying Keycloak to Google Cloud Run (Canada Region)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION (Montreal, Canada)"
echo "Service: $SERVICE_NAME"
echo ""

# Set GCP project
echo "📍 Setting GCP project..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔌 Enabling required GCP APIs..."
gcloud services enable \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  containerregistry.googleapis.com \
  --quiet

# Create Artifact Registry repository (Canada region)
echo "📦 Creating Artifact Registry repository in Canada..."
gcloud artifacts repositories create quantoflow \
  --repository-format=docker \
  --location=$REGION \
  --description="Quantoflow Keycloak - Canada" \
  --quiet 2>/dev/null || echo "Repository already exists"

# Configure Docker authentication
echo "🔐 Configuring Docker authentication..."
gcloud auth configure-docker $REGION-docker.pkg.dev

# Build and push Docker image
echo "🔨 Building Docker image..."
gcloud builds submit \
  --tag $REGION-docker.pkg.dev/$PROJECT_ID/quantoflow/$IMAGE_NAME:latest \
  --region $REGION \
  --machine-type N1_HIGHCPU_8

echo "✅ Image pushed to Artifact Registry"
echo ""

# Deploy to Cloud Run
echo "🚀 Deploying to Cloud Run (Canada)..."
gcloud run deploy $SERVICE_NAME \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/quantoflow/$IMAGE_NAME:latest \
  --platform managed \
  --region $REGION \
  --memory 2Gi \
  --cpu 2 \
  --timeout 3600 \
  --max-instances 10 \
  --allow-unauthenticated \
  --ingress all \
  --set-env-vars \
    DB_USERNAME=postgres,\
    DB_PASSWORD=$DB_PASSWORD,\
    DB_HOST=$DB_HOST,\
    DB_PORT=5432,\
    DB_NAME=keycloak \
  --quiet

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Deployment Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
  --region $REGION \
  --platform managed \
  --format 'value(status.url)')

echo "🌐 Service URL (Canada):"
echo "   $SERVICE_URL"
echo ""
echo "📊 View logs:"
echo "   gcloud run logs read $SERVICE_NAME --region $REGION --limit 50"
echo ""
echo "🔧 View service details:"
echo "   gcloud run services describe $SERVICE_NAME --region $REGION"
echo ""
echo "⚙️  To set a custom domain (auth.yourdomain.com):"
echo "   gcloud run domain-mappings create --service $SERVICE_NAME --domain auth.yourdomain.com --region $REGION"
echo ""
