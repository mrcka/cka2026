#!/bin/bash

echo "Deleting Calico Tigera Operator..."
kubectl delete -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml

echo "Deleting tigera-operator namespace..."
kubectl delete namespace tigera-operator --ignore-not-found=true

echo "Deleting calico-system namespace..."
kubectl delete namespace calico-system --ignore-not-found=true

echo "Calico operator and namespaces removed."
