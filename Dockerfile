# Usar alpine como base ao invés de ubuntu para uma imagem mais leve
FROM alpine:3.19

# Combinar comandos RUN para reduzir camadas e usar cache de maneira eficiente
RUN apk update && \
    apk add --no-cache \
        curl \
        sudo \
        unzip \
        ufw \
        fail2ban \
        git \
        bash && \
    # Criar usuário e configurar sudo em uma única camada
    adduser -D -s /bin/bash mailuser && \
    echo "mailuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # Criar diretório e ajustar permissões na mesma camada
    mkdir -p /var/lib/mailinabox && \
    chown -R mailuser:mailuser /var/lib/mailinabox && \
    # Limpar cache do apk para reduzir tamanho
    rm -rf /var/cache/apk/*

# Copiar entrypoint e configurar permissões em uma única camada
COPY --chmod=755 entrypoint.sh /usr/local/bin/

# Configurar download do setup em uma única camada como mailuser
USER mailuser
WORKDIR /home/mailuser
RUN curl -sSL https://mailinabox.email/setup.sh -o setup.sh && \
    chmod +x setup.sh

# Configurações finais
USER root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EXPOSE 25 53 80 443 587 993 995
VOLUME ["/home/mailuser", "/var/lib/mailinabox"]
