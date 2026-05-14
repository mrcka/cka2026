#!/bin/bash
set -e

# Step 1: Create namespace for cert-manager
kubectl create namespace cert-manager || echo "Namespace cert-manager already exists"

# Step 2: Apply cert-manager installation manifest
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.2/cert-manager.yaml

echo "✅ cert-manager installed successfully in namespace cert-manager"
