#!/bin/bash
# scripts/verify-config.sh

echo "=== VERIFICACIÓN DE CONFIGURACIÓN PRIVOXY ==="

# Verificar archivos de configuración
echo "1. Verificando archivos de configuración..."

for config_file in config/padre/config config/hijos/hijo1/config config/hijos/hijo2/config config/hijos/hijo3/config config/hijos/hijo4/config; do
    if [ -f "$config_file" ]; then
        echo "✅ $config_file existe"
        
        # Verificar sintaxis básica
        if grep -q "forward" "$config_file"; then
            forward_lines=$(grep "forward" "$config_file" | wc -l)
            echo "   - Contiene $forward_lines líneas forward"
        fi
    else
        echo "❌ $config_file NO existe"
    fi
done

# Verificar archivos de acciones
echo "2. Verificando archivos de acciones..."

for action_file in config/padre/match-all.action config/padre/default.action \
                   config/hijos/hijo1/match-all.action config/hijos/hijo1/default.action \
                   config/hijos/hijo2/match-all.action config/hijos/hijo2/default.action \
                   config/hijos/hijo3/match-all.action config/hijos/hijo3/default.action\
                   config/hijos/hijo4/match-all.action config/hijos/hijo3/default.action; do
    if [ -f "$action_file" ]; then
        echo "✅ $action_file existe"
    else
        echo "❌ $action_file NO existe"
    fi
done

# Verificar sintaxis de configuración del padre
echo "3. Verificando sintaxis del balanceador padre..."
if docker run --rm -v $(pwd)/config/padre:/etc/privoxy privoxy-image privoxy --no-daemon --test /etc/privoxy/config 2>/dev/null; then
    echo "✅ Configuración del padre es válida"
else
    echo "❌ Configuración del padre tiene errores"
fi

echo "=== VERIFICACIÓN COMPLETADA ==="