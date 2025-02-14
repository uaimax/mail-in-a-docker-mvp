FROM ubuntu:22.04

# Definir ambiente como não interativo
ARG DEBIAN_FRONTEND=noninteractive
ENV PRIMARY_HOSTNAME=${PRIMARY_HOSTNAME}
ENV ADMIN_EMAIL=${ADMIN_EMAIL}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}
ENV DISABLE_DNS=${DISABLE_DNS}
ENV TLS_FLAVOR=${TLS_FLAVOR}

# Atualizar pacotes e instalar dependências básicas
RUN apt update && apt -y upgrade && \
    apt -y install curl sudo unzip ufw fail2ban git && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Criar usuário para rodar o Mail-in-a-Box
RUN useradd -m -s /bin/bash mailuser && echo "mailuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Baixar e instalar Mail-in-a-Box
USER mailuser
WORKDIR /home/mailuser
RUN curl -sSL https://mailinabox.email/setup.sh -o setup.sh && chmod +x setup.sh

# Executar instalação automática com variáveis de ambiente
RUN echo -e "${PRIMARY_HOSTNAME}\n${ADMIN_EMAIL}\n${ADMIN_PASSWORD}\n${DISABLE_DNS}\n${TLS_FLAVOR}" | sudo -E ./setup.sh

# Expor portas necessárias
EXPOSE 25 53 80 443 587 993 995

# Volumes para persistência
VOLUME ["/home/mailuser", "/var/lib/mailinabox"]

# Rodar o Mail-in-a-Box
CMD ["/usr/bin/bash", "-c", "mailinabox"]
