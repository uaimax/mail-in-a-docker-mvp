# Usar ubuntu:22.04 que é requerido pelo Mail-in-a-Box
FROM ubuntu:22.04

# Definir ambiente como não interativo e combinar camadas para reduzir tamanho
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        sudo \
        unzip \
        ufw \
        fail2ban \
        git \
        lsb-release \
        systemctl \
        ca-certificates \
        locales && \
    # Configurar locale
    locale-gen en_US.UTF-8 && \
    # Criar usuário e configurar na mesma camada
    useradd -m -s /bin/bash mailuser && \
    echo "mailuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # Criar diretório e ajustar permissões
    mkdir -p /var/lib/mailinabox && \
    chown -R mailuser:mailuser /var/lib/mailinabox && \
    # Limpar cache e arquivos temporários
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Definir variáveis de ambiente para locale
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Copiar e configurar entrypoint em uma única camada
COPY --chmod=755 entrypoint.sh /usr/local/bin/

# Configurar download do setup como mailuser
USER mailuser
WORKDIR /home/mailuser
RUN curl -sSL https://mailinabox.email/setup.sh -o setup.sh && \
    chmod +x setup.sh

# Configurações finais
USER root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EXPOSE 25 53 80 443 587 993 995
VOLUME ["/home/mailuser", "/var/lib/mailinabox"]
