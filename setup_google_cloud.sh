#!/bin/bash

# Variables generales
PROJECT_ID="nuevo-proyecto"
REGION="us-central1"
CLUSTER_ZONE="us-central1-a"
INSTANCE_ID="venezuelalibre-instance"
TABLE_ID="mapa_puntos"
SECRET_ID="CLAVEMAP"
SECRET_VALUE="TU_CLAVE_API"
BUCKET_NAME="frontend-bucket"

# 1. Crear un nuevo proyecto
echo "Creando proyecto..."
gcloud projects create $PROJECT_ID --name="Nuevo Proyecto de Mapa"

# 2. Establecer el proyecto activo
echo "Estableciendo proyecto activo..."
gcloud config set project $PROJECT_ID

# 3. Habilitar las APIs necesarias
echo "Habilitando APIs necesarias..."
gcloud services enable \
    compute.googleapis.com \
    run.googleapis.com \
    secretmanager.googleapis.com \
    cloudbuild.googleapis.com \
    bigtable.googleapis.com \
    bigtableadmin.googleapis.com \
    storage.googleapis.com

# 4. Crear instancia de Bigtable
echo "Creando instancia de Bigtable..."
gcloud bigtable instances create $INSTANCE_ID \
    --cluster=$INSTANCE_ID-cluster \
    --cluster-zone=$CLUSTER_ZONE \
    --display-name="Instancia de Bigtable"

# 5. Crear tabla en Bigtable
echo "Creando tabla en Bigtable..."
gcloud bigtable tables create $TABLE_ID --instance=$INSTANCE_ID

# 6. Crear secreto en Secret Manager
echo "Creando secreto en Secret Manager..."
echo -n $SECRET_VALUE | gcloud secrets create $SECRET_ID --data-file=-

# 7. Asignar permisos al servicio de Cloud Run para acceder a Secret Manager
SERVICE_ACCOUNT_EMAIL="$(gcloud iam service-accounts list --filter='Compute Engine default' --format='value(email)')"
echo "Asignando permisos para acceder a Secret Manager..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/secretmanager.secretAccessor"

# 8. Crear bucket para almacenar el frontend
echo "Creando bucket para el frontend..."
gcloud storage buckets create $BUCKET_NAME --location=$REGION

# 9. Subir frontend al bucket
echo "Subiendo frontend al bucket..."
gsutil cp ./index.html gs://$BUCKET_NAME/

# 10. Configurar el backend en Cloud Run
echo "Construyendo y desplegando el backend en Cloud Run..."
docker build -t gcr.io/$PROJECT_ID/venezuelalibre-backend:latest .
docker push gcr.io/$PROJECT_ID/venezuelalibre-backend:latest
gcloud run deploy venezuelalibre-backend \
    --image=gcr.io/$PROJECT_ID/venezuelalibre-backend:latest \
    --region=$REGION \
    --allow-unauthenticated

echo "Automatización completada exitosamente. 🎉"