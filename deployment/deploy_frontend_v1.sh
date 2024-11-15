#!/bin/bash
REGION="us-central1"
PROJECT_ID="hw5-20290456"

# Configuration for frontend_v1
SERVICE_NAME="frontend-v1"
IMAGE_URI="us-central1-docker.pkg.dev/hw5-20290456/hw5-images/frontend_v1:latest"
SERVING_PORT="8000"

# Add the backend URL in environment variables
BACKEND_URL="https://backend-v1-917104755283.us-central1.run.app"

gcloud run deploy ${SERVICE_NAME} \
    --region=${REGION} \
    --image=${IMAGE_URI} \
    --min-instances=1 \
    --max-instances=1 \
    --memory="2Gi" \
    --cpu=2 \
    --port=${SERVING_PORT} \
    --allow-unauthenticated \
    --set-env-vars="SERVING_URL=${BACKEND_URL},SERVING_PORT=${SERVING_PORT}"
