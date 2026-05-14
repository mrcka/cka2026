#!/bin/bash
set -e

# Step 1: Create namespace
kubectl create namespace mrdb || echo "Namespace mrdb already exists"

# Step 2: Create PersistentVolume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mrdb-pv
spec:
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: "/mnt/data/mrdb"
EOF

# Step 3: Create Deployment with PVC reference
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mrdb
  namespace: mrdb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: local-mrdb
  template:
    metadata:
      labels:
        app: local-mrdb
    spec:
      containers:
      - name: mrdb
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "rootpassword"
        ports:
        - containerPort: 3306
        volumeMounts:
        - mountPath: /var/lib/mysql
          name: mrdb-storage
      volumes:
      - name: mrdb-storage
        persistentVolumeClaim:
          claimName: mrdb-pvc
EOF

# Step 4: Create PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mrdb-pvc
  namespace: mrdb
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
  storageClassName: manual
EOF

echo "✅ MySQL deployment with PV/PVC applied successfully in namespace mrdb"
