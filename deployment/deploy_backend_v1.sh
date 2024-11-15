#!/bin/bash
REGION="us-central1"
PROJECT_ID="hw5-20290456"

# Configuration pour backend_v1
SERVICE_NAME="backend-v1"
IMAGE_URI="us-central1-docker.pkg.dev/hw5-20290456/hw5-images/backend_v1:latest"
SERVING_PORT="8000"

gcloud run deploy ${SERVICE_NAME} \
    --region=${REGION} \
    --image=${IMAGE_URI} \
    --min-instances=1 \
    --max-instances=1 \
    --memory="2Gi" \
    --cpu=2 \
    --port=${SERVING_PORT} \
    --allow-unauthenticated \
    --set-env-vars="SERVING_PORT=${SERVING_PORT}"
