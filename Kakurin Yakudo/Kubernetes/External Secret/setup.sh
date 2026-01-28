#!/bin/bash

trap 'echo ""; exit 1' INT

echo "======================================================"
echo "      ◆ External Secrets Operator Installer"
echo "======================================================"
echo "◈ Adding Helm repository..."
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

DEFAULT_PORT="9443"
while true; do
    read -p "▶ Enter Webhook Port Number [$DEFAULT_PORT]: " CUSTOM_PORT
    CUSTOM_PORT=${CUSTOM_PORT:-$DEFAULT_PORT}

    if lsof -Pi :$CUSTOM_PORT -sTCP:LISTEN -t >/dev/null ; then
        echo "[!] Error: Port $CUSTOM_PORT is already in use."
        echo "    Please enter a different port number."
    else
        break
    fi
done

echo "◈ Installing External Secrets Operator..."
helm upgrade -i external-secrets external-secrets/external-secrets \
    --namespace external-secrets \
    --create-namespace \
    --set installCRDs=true \
    --set webhook.port=$CUSTOM_PORT

echo "◈ Waiting for External Secrets pods to be ready..."
kubectl wait --namespace external-secrets \
    --for=condition=ready pod \
    -l "app.kubernetes.io/instance=external-secrets" \
    --timeout=300s

echo "-------------------------------------------------------"
echo "                      (～￣▽￣)～"
echo "◈ External Secrets Operator is Ready!"
echo "   - Namespace: external-secrets"
echo "   - Webhook Port: ${CUSTOM_PORT}"
echo "-------------------------------------------------------"
echo "◈ Next Steps:"
echo "   1. Create a SecretStore or ClusterSecretStore"
echo "   2. Define your ExternalSecret to sync AWS Secrets"
echo "-------------------------------------------------------"

echo "[✔] Installation completed successfully!"