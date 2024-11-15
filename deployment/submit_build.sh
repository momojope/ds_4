#!/bin/bash
REGION="us-central1" # Région où déployer
PROJECT_ID="hw5-20290456" # ID du projet Google Cloud

# This makes sure that we are uploading our code from the proper path.
# Don't change this line.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

REPO_NAME="hw5-images" # Nom du dépôt dans l'Artifact Registry
REGISTRY="us-central1-docker.pkg.dev" # URI du registre
APP_IMAGE="$1" # Nom de l'image (frontend_v1, backend_v1, frontend_v2, or backend_v2)
TARGET_DOCKERFILE="Dockerfile.${APP_IMAGE}" # Dockerfile à utiliser
SERVING_PORT=8000 # Port sur lequel le service écoute

# Vérifier si un argument est passé pour le nom de l'image
if [ -z "$APP_IMAGE" ]; then
echo "Veuillez fournir le nom de l'image en tant qu'argument (frontend_v1, backend_v1, frontend_v2, or backend_v2)."
exit 1
fi

# Définir les URI complets du dépôt
REPO_URI="${REGISTRY}/${PROJECT_ID}/${REPO_NAME}"
BASE_IMAGE_URI="${REPO_URI}/base_image"
APP_URI="${REPO_URI}/${APP_IMAGE}"

# Exécuter la commande de build et soumettre à Google Cloud Build
gcloud builds submit \
    --region=${REGION} \
    --config="${SCRIPT_DIR}/cloudbuild.yaml" \
    --substitutions=_BASE_IMAGE_URI="${BASE_IMAGE_URI}",_APP_URI="${APP_URI}",_SERVING_PORT=${SERVING_PORT},_TARGET_DOCKERFILE="${TARGET_DOCKERFILE}" \
    ${SCRIPT_DIR}/../
