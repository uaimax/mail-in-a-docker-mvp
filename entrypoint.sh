#!/bin/bash
set -eo pipefail

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
    # Iniciar serviços usando o comando direto em vez de 'service'
    echo "🔄 Iniciando serviços..."
    
    # Postfix
    if [ -f /usr/sbin/postfix ]; then
        /usr/sbin/postfix start || {
            echo "❌ Falha ao iniciar postfix"
            return 1
        }
    fi
    
    # Dovecot
    if [ -f /usr/sbin/dovecot ]; then
        /usr/sbin/dovecot || {
            echo "❌ Falha ao iniciar dovecot"
            return 1
        }
    fi
    
    # OpenDKIM
    if [ -f /usr/sbin/opendkim ]; then
        /usr/sbin/opendkim || {
            echo "❌ Falha ao iniciar opendkim"
            return 1
        }
    fi
    
    # Nginx
    if [ -f /usr/sbin/nginx ]; then
        /usr/sbin/nginx || {
            echo "❌ Falha ao iniciar nginx"
            return 1
        }
    fi
    
    return 0
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
        
        # Marca a instalação como concluída
        touch /var/lib/mailinabox/.installed
    else
        echo "✅ Mail-in-a-Box já instalado."
    fi
    
    # Inicia os serviços
    if ! start_services; then
        echo "❌ Falha ao iniciar alguns serviços"
        exit 1
    fi
    
    echo "✅ Todos os serviços iniciados com sucesso"
    
    # Cria diretório de logs se não existir
    mkdir -p /var/log
    touch /var/log/syslog
    
    # Mantém o container rodando e monitora logs
    exec tail -f /var/log/syslog
}

# Executa a função principal
main "$@"
