#!/bin/bash
set -eo pipefail

# Função para verificar variáveis de ambiente obrigatórias
check_required_vars() {
    local required_vars=("PRIMARY_HOSTNAME" "ADMIN_EMAIL" "ADMIN_PASSWORD")
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "❌ Erro: Variável $var não está definida"
            exit 1
        fi
    done
}

# Função principal
main() {
    # Verifica variáveis de ambiente
    check_required_vars
    
    if [ ! -f /var/lib/mailinabox/.installed ]; then
        echo "⚙️ Instalando o Mail-in-a-Box..."
        
        # Configura as variáveis de ambiente com valores default para opcionais
        export DISABLE_DNS=${DISABLE_DNS:-0}
        export TLS_FLAVOR=${TLS_FLAVOR:-letsencrypt}
        
        # Executa a instalação
        if ! sudo -E bash /home/mailuser/setup.sh; then
            echo "❌ Falha na instalação do Mail-in-a-Box"
            exit 1
        fi
        
        touch /var/lib/mailinabox/.installed
    else
        echo "✅ Mail-in-a-Box já instalado."
    fi
    
    # Deixa o Dokploy gerenciar o processo
    exec "$@"
}

main "$@"
