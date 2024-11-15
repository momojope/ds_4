#!/bin/bash
REGION="us-central1"
PROJECT_ID="hw5-20290456"
SERVICE_NAME="frontend-v2"
IMAGE_URI="us-central1-docker.pkg.dev/hw5-20290456/hw5-images/frontend_v2:latest"
SERVING_URL="https://backend-v2-o6aftokpwq-uc.a.run.app"

gcloud run deploy ${SERVICE_NAME} \
    --region=${REGION} \
    --image=${IMAGE_URI} \
    --min-instances=1 \
    --max-instances=1 \
    --memory="2Gi" \
    --cpu=2 \
    --allow-unauthenticated \
    --set-env-vars="SERVING_URL=${SERVING_URL}"
