#!/bin/bash
# scripts/startup.sh

set -e

echo "Iniciando servicio Privoxy: ${INSTANCE_TYPE:-unknown}"

# Copiar archivos de acciones básicos si no existen
if [ ! -f /etc/privoxy/match-all.action ]; then
    echo "Copiando archivos de acciones por defecto..."
    cp /tmp/privoxy/*.action /etc/privoxy/ 2>/dev/null || true
    cp /tmp/privoxy/*.filter /etc/privoxy/ 2>/dev/null || true
fi

chmod 644 /etc/privoxy/default.filter
chown root:root /etc/privoxy/default.filter

if [ "$INSTANCE_TYPE" = "padre" ]; then
    echo "Iniciando balanceador padre..."
    exec privoxy --no-daemon /etc/privoxy/config

elif [ "$INSTANCE_TYPE" = "hijo" ]; then
    echo "Configurando hijo $INSTANCE_NUMBER con interfaz $INTERFACE en puerto $PORT"
    
    # Configuración de red específica por interfaz
    configure_interface() {
        local interface=$1
        local instance_num=$2
        
        # Verificar si la interfaz existe
        if ip link show $interface >/dev/null 2>&1; then
            INTERFACE_IP=$(ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [ -n "$INTERFACE_IP" ]; then
                echo "Hijo $instance_num usando interfaz $interface ($INTERFACE_IP)"
                
                # Configurar políticas de ruteo
                ip route add default via $INTERFACE_IP dev $interface table $((100 + instance_num)) || true
                ip rule add from $INTERFACE_IP table $((100 + instance_num)) || true
            else
                echo "ADVERTENCIA: No se pudo obtener IP para $interface, usando configuración por defecto"
            fi
        else
            echo "ADVERTENCIA: Interfaz $interface no encontrada, usando configuración por defecto"
        fi
    }
    
    # Configurar la interfaz específica
    configure_interface "$INTERFACE" "$INSTANCE_NUMBER"
    
    echo "Iniciando Privoxy hijo $INSTANCE_NUMBER..."
    exec privoxy --no-daemon /etc/privoxy/config
else
    echo "Iniciando Privoxy en modo simple..."
    exec privoxy --no-daemon /etc/privoxy/config
fi