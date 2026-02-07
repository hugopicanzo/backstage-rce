#!/bin/bash
echo "--- BUSCANDO TOKEN ---"
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

echo "--- BUSCANDO ROL ---"
ROLE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/)
echo "Rol encontrado: $ROLE"

echo "--- BUSCANDO LLAVES ---"
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/$ROLE
