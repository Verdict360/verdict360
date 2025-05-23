#!/bin/bash

# Source the .env file to get credentials
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Use the credentials from .env, fallback to defaults if not set
MINIO_USER=${MINIO_ROOT_USER:-minioadmin}
MINIO_PASS=${MINIO_ROOT_PASSWORD:-minioadmin}

echo "Using MinIO credentials from .env"

# Wait for MinIO to be ready
echo "Waiting for MinIO to be ready..."
sleep 5

# Clear any existing aliases to avoid conflicts
mc alias remove myminio 2>/dev/null || true

# Set up MinIO client with credentials from .env
echo "Setting up MinIO alias with user: $MINIO_USER"
mc alias set myminio http://localhost:9000 "$MINIO_USER" "$MINIO_PASS"

# Create buckets
echo "Creating legal document buckets..."
mc mb myminio/legal-documents --quiet || echo "Bucket already exists"
mc mb myminio/legal-recordings --quiet || echo "Bucket already exists"
mc mb myminio/legal-transcriptions --quiet || echo "Bucket already exists"

# Set bucket policies using the new 'anonymous' command
echo "Setting bucket policies..."
mc anonymous set download myminio/legal-documents
mc anonymous set download myminio/legal-recordings
mc anonymous set download myminio/legal-transcriptions

echo "MinIO setup complete!"
