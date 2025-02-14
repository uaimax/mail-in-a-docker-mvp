FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        sudo \
        unzip \
        ufw \
        fail2ban \
        git \
        lsb-release \
        ca-certificates \
        locales \
        dialog \
        apt-utils && \
    locale-gen en_US.UTF-8 && \
    useradd -m -s /bin/bash mailuser && \
    echo "mailuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /var/lib/mailinabox && \
    chown -R mailuser:mailuser /var/lib/mailinabox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=755 entrypoint.sh /usr/local/bin/

USER mailuser
WORKDIR /home/mailuser
RUN curl -sSL https://mailinabox.email/setup.sh -o setup.sh && \
    chmod +x setup.sh

USER root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]

EXPOSE 25 53 80 443 587 993 995
VOLUME ["/home/mailuser", "/var/lib/mailinabox"]
