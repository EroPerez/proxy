#!/bin/bash
# scripts/healthcheck.sh

INSTANCE_TYPE=${1:-default}

case $INSTANCE_TYPE in
    "padre")
        # Verificar que el balanceador responde
        echo "Verificando salud del padre..."
        if curl -f -s -o /dev/null --connect-timeout 5 http://localhost:8080/; then
            exit 0
        else
            exit 1
        fi
        ;;
    "hijo")
        # Verificar que el hijo responde
        echo "Verificando salud del hijo $INSTANCE_NUMBER..."
        PORT=${PORT:-8118}
        if curl -f -s -o /dev/null --connect-timeout 5 http://localhost:$PORT/; then
            exit 0
        else
            exit 1
        fi
        ;;
    "default")
        # Healthcheck por defecto - verificar proceso
        echo "Verificando salud por defecto..."
        if pgrep privoxy > /dev/null; then
            exit 0
        else
            exit 1
        fi
        ;;
esac