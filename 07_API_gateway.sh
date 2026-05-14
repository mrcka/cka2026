#!/bin/bash
set -e

# Step 1: Run Nginx Pod
kubectl run web-pod --image=nginx --port=80

# Step 2: Expose Pod as Service
kubectl expose pod web-pod --name=web-service --port=80 --target-port=80

# Step 3: Verify Service
kubectl get svc web-service

# Step 4: Create TLS Secret
kubectl create secret tls tls-secret \
  --cert=/etc/kubernetes/pki/apiserver.crt \
  --key=/etc/kubernetes/pki/apiserver.key

# Step 5: Apply Ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
spec:
  tls:
  - hosts:
    - gateway.web.k8s.local
    secretName: tls-secret
  rules:
  - host: gateway.web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
EOF

# Step 6: Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

# Step 7: Create GatewayClass
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: k8s.io/nginx-gateway-controller
EOF

# Step 8: Create Gateway
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
EOF

echo "✅ Web pod, service, ingress, and gateway setup completed"
