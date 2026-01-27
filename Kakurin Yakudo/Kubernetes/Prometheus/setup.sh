#!/bin/bash

kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
parameters:
  type: gp3
  fsType: ext4
provisioner: ebs.csi.aws.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF

k create ns prometheus

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm upgrade -i prometheus prometheus-community/prometheus \
    --namespace prometheus

echo "Waiting for Prometheus server pod to be ready..."

kubectl wait --namespace prometheus \
    --for=condition=ready pod \
    -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" \
    --timeout=300s

export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")

echo "-------------------------------------------------------"
echo "ヾ(≧▽≦*)o Port-Forwarding: http://localhost:59090"
echo "Target Pod: $POD_NAME"
echo "-------------------------------------------------------"

kubectl --namespace prometheus port-forward $POD_NAME 59090:9090 --address 0.0.0.0 &