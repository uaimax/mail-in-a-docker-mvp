#!/bin/bash

# Verifica se o Mail-in-a-Box já foi instalado
if [ ! -f /var/lib/mailinabox/.installed ]; then
    echo "⚙️ Instalando o Mail-in-a-Box..."
    
    # Configura as variáveis passadas pelo Docker
    export PRIMARY_HOSTNAME=${PRIMARY_HOSTNAME}
    export ADMIN_EMAIL=${ADMIN_EMAIL}
    export ADMIN_PASSWORD=${ADMIN_PASSWORD}
    export DISABLE_DNS=${DISABLE_DNS}
    export TLS_FLAVOR=${TLS_FLAVOR}

    # Executa a instalação interativa
    sudo -E /home/mailuser/setup.sh
    
    # Marca a instalação como concluída
    touch /var/lib/mailinabox/.installed
else
    echo "✅ Mail-in-a-Box já instalado."
fi

# Iniciar serviços essenciais
echo "🚀 Iniciando serviços..."
service postfix start
service dovecot start
service opendkim start
service nginx start

# Mantém o container rodando
tail -f /var/log/syslog
