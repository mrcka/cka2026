#!/bin/bash

echo "Applying Namespace, PriorityClass, and Deployment..."

kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: priority
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: highest-user-priority
value: 1000000
globalDefault: false
description: "This priority class should be used for XYZ service pods only."
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-logger
  namespace: priority
spec:
  replicas: 2
  selector:
    matchLabels:
      app: busybox-logger
  template:
    metadata:
      labels:
        app: busybox-logger
    spec:
      containers:
      - name: busybox
        image: busybox
        args:
        - /bin/sh
        - -c
        - "while true; do echo Logging; sleep 5; done"
EOF

echo "Resources created successfully."
