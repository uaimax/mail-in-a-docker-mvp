#!/bin/bash
set -eo pipefail  # Faz o script falhar em caso de erros

# Função para verificar variáveis de ambiente obrigatórias
check_required_vars() {
    local required_vars=("PRIMARY_HOSTNAME" "ADMIN_EMAIL" "ADMIN_PASSWORD")
    local missing_vars=0
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "❌ Erro: Variável $var não está definida"
            missing_vars=1
        fi
    done
    
    if [ $missing_vars -eq 1 ]; then
        exit 1
    fi
}

# Função para iniciar serviços
start_services() {
    local services=("postfix" "dovecot" "opendkim" "nginx")
    
    for service in "${services[@]}"; do
        echo "🔄 Iniciando $service..."
        if ! service "$service" start; then
            echo "❌ Falha ao iniciar $service"
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
        if ! sudo -E /home/mailuser/setup.sh; then
            echo "❌ Falha na instalação do Mail-in-a-Box"
            exit 1
        fi
        
        # Marca a instalação como concluída
        touch /var/lib/mailinabox/.installed
    else
        echo "✅ Mail-in-a-Box já instalado."
    fi
    
    # Inicia os serviços
    start_services
    
    echo "✅ Todos os serviços iniciados com sucesso"
    
    # Cria diretório de logs se não existir
    mkdir -p /var/log
    touch /var/log/syslog
    
    # Mantém o container rodando e monitora logs
    exec tail -f /var/log/syslog
}

# Executa a função principal
main "$@"
