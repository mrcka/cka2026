#!/bin/bash
set -e

# Step 1: Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Step 2: Patch Metrics Server to allow insecure TLS
kubectl -n kube-system patch deployment metrics-server \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# Step 3: Wait for rollout to complete
kubectl rollout status deployment metrics-server -n kube-system

# Step 4: Create autoscaler namespace and deploy mrapp
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: autoscaler
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mrapp
  namespace: autoscaler
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mrapp
  template:
    metadata:
      labels:
        app: mrapp
    spec:
      containers:
      - name: mrapp
        image: httpd:latest
        resources:
          requests:
            cpu: 100m
          limits:
            cpu: 200m
EOF
