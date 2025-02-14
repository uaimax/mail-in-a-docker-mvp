FROM ubuntu:22.04

# Definir ambiente como não interativo
ARG DEBIAN_FRONTEND=noninteractive

# Atualizar pacotes e instalar dependências básicas
RUN apt update && apt -y upgrade && \
    apt -y install curl sudo unzip ufw fail2ban git && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Criar usuário para rodar o Mail-in-a-Box
RUN useradd -m -s /bin/bash mailuser && echo "mailuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copiar script de entrada antes de trocar o usuário
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Trocar para o usuário mailuser
USER mailuser
WORKDIR /home/mailuser

# Baixar o instalador do Mail-in-a-Box
RUN curl -sSL https://mailinabox.email/setup.sh -o setup.sh && chmod +x setup.sh

# Definir variáveis que serão passadas na execução
ENV PRIMARY_HOSTNAME=""
ENV ADMIN_EMAIL=""
ENV ADMIN_PASSWORD=""
ENV DISABLE_DNS="TRUE"
ENV TLS_FLAVOR="letsencrypt"

# Expor portas necessárias
EXPOSE 25 53 80 443 587 993 995

# Volumes para persistência
VOLUME ["/home/mailuser", "/var/lib/mailinabox"]

# Definir entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
