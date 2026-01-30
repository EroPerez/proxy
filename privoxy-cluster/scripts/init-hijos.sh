#!/bin/bash
# scripts/init-hijos.sh

set -e

source .env

echo "=== INICIALIZACION DE CONFIGURACIONES PRIVOXY ==="

# Crear directorios necesarios
mkdir -p config/padre config/hijos/hijo{1,2,3,4} logs/{padre,hijos/hijo{1,2,3,4}}

# Copiar archivos de acciones a todos los directorios
echo "Copiando archivos de acciones base..."

for dir in config/padre config/hijos/hijo1 config/hijos/hijo2 config/hijos/hijo3 config/hijos/hijo4; do
    cp config/templates/match-all.action $dir/
    cp config/templates/default.action $dir/
    cp config/templates/default.filter $dir/ 2>/dev/null || true
done

# Generar configuraciones para hijos
for i in 1 2 3, 4; do   
    PORT=$((HIJOS_PORT_BASE + i - 1))
    
    echo "Generando configuracion para hijo $i (puerto: $PORT)"
    
    # Crear configuracion desde template
    INTERFACE_VAR="HIJO${i}_INTERFACE"
    export INTERFACE=${!INTERFACE_VAR}
    export INSTANCE_NUMBER=$i
    export PORT=$PORT
    envsubst '$INSTANCE_NUMBER $PORT' < config/templates/config-hijo.template > config/hijos/hijo$i/config
    
    echo "Hijo $i configurado en puerto $PORT"
done

# Configuraci¨®n del padre
echo "Generando configuracion para el balanceador padre..."
cp config/templates/config-padre.template config/padre/config

echo "=== CONFIGURACIONES GENERADAS EXITOSAMENTE ==="