#!/bin/bash
set -e

# Step 1: Create namespace
kubectl create namespace mrapp || echo "Namespace mrapp already exists"

# Step 2: Apply Deployment with containerPort defined
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: front-end
  namespace: mrapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: front-end
  template:
    metadata:
      labels:
        app: front-end
    spec:
      containers:
      - name: nginx-container
        image: nginx:latest
        ports:
        - containerPort: 80   # ✅ Added containerPort
EOF

# Step 3: Expose Deployment as Service
kubectl expose deployment front-end \
  -n mrapp \
  --name=front-end-service \
  --port=80 \
  --target-port=80

# Step 4: Verify Service
kubectl get svc -n mrapp

echo "✅ Front-end Deployment and Service applied successfully"
