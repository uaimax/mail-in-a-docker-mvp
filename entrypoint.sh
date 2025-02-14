#!/bin/bash

# Verifica se o Mail-in-a-Box já foi instalado
if [ ! -f /var/lib/mailinabox/.installed ]; then
    echo "⚙️ Instalando o Mail-in-a-Box..."
    
    # Executa a instalação interativa
    sudo -E ./setup.sh
    
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
