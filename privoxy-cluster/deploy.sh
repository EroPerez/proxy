#!/bin/bash
# deploy.sh

set -e

echo "=== DESPLIEGUE CLUSTER PRIVOXY ==="

# Hacer ejecutables los scripts
chmod +x scripts/*.sh

# 1. Generar configuraciones
echo "Generando configuraciones..."
./scripts/init-hijos.sh

# Verificar configuraciones
echo "Verificando configuraciones..."
./scripts/verify-config.sh

# 2. Construir imagenes
echo "Construyendo imagenes Docker..."
docker-compose down && docker-compose build

# 3. Iniciar servicios
echo "Iniciando cluster..."
docker-compose up -d --force-recreate

# 4. Esperar inicializacion
echo "Esperando inicializacion de servicios..."
sleep 10

# 5. Verificar estado
echo "Verificando estado de servicios..."
docker-compose ps

# 6. Test de funcionamiento
echo "Realizando test de conectividad..."
curl -x http://localhost:8080 http://ifconfig.me

echo "\n=== DESPLIEGUE COMPLETADO ==="