#!/bin/bash
set -e

# Create Deployment for mrapp
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mrapp-deployment
  namespace: default
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
        - name: monitor
          image: lfcert/monitor:latest
          env:
            - name: LOG_FILENAME
              value: /var/log/mrapp.log
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      tolerations:
        - effect: NoExecute
          key: node.kubernetes.io/not-ready
          operator: Exists
          tolerationSeconds: 300
        - effect: NoExecute
          key: node.kubernetes.io/unreachable
          operator: Exists
          tolerationSeconds: 300
EOF

echo "✅ mrapp-deployment applied successfully"
