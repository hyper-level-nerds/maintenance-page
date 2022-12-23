FROM docker.io/library/ubuntu:jammy

ARG TARGETARCH

LABEL org.opencontainers.image.authors="https://bitnami.com/contact; https://sidlibrary.org" \
      org.opencontainers.image.description="Application packaged by Bitnami; flavoured by Sidney Jeong" \
      org.opencontainers.image.ref.name="1.23.3-jammy-r1" \
      org.opencontainers.image.source="https://github.com/bitnami/containers/tree/main/bitnami/nginx" \
      org.opencontainers.image.title="nginx" \
      org.opencontainers.image.vendor="VMware, Inc.; Sidney Jeong" \
      org.opencontainers.image.version="1.23.3"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="ubuntu-22.04" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN apt-get update && apt-get -y install software-properties-common apt-transport-https apt-utils ca-certificates acl gnupg curl lsb-release ubuntu-keyring && \
    apt-get -y install libcrypt1 libgeoip1 libpcre3 libssl3 procps zlib1g gosu git && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor > /usr/share/keyrings/nginx-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu \
    $(lsb_release -cs) nginx" > /etc/apt/sources.list.d/nginx.list && \
    apt-get update && apt-get -y install nginx
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN mkdir -p /opt/bitnami/nginx/logs /opt/bitnami/nginx/html /opt/bitnami/nginx/tmp /opt/bitnami/nginx/sbin /opt/bitnami/nginx/server_blocks && \
    cp -av /etc/nginx /opt/bitnami/nginx/conf && chmod -R g+rwX /opt/bitnami
RUN ln -sf /dev/stdout /opt/bitnami/nginx/logs/access.log && \
    ln -sf /dev/stderr /opt/bitnami/nginx/logs/error.log

COPY rootfs /
RUN cp -av /usr/sbin/nginx /opt/bitnami/nginx/sbin/nginx && \
    chmod -R g+rwX /opt/bitnami
RUN /opt/bitnami/scripts/nginx/postunpack.sh
RUN ln -sfr /lib/x86_64-linux-gnu/libssl.so.3 /lib/x86_64-linux-gnu/libssl.so.1.1 && \
    ln -sfr /lib/x86_64-linux-gnu/libcrypto.so.3 /lib/x86_64-linux-gnu/libcrypto.so.1.1
ENV APP_VERSION="1.23.3" \
    BITNAMI_APP_NAME="nginx" \
    NGINX_HTTPS_PORT_NUMBER="" \
    NGINX_HTTP_PORT_NUMBER="" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/nginx/sbin:$PATH"

EXPOSE 8080 8443

WORKDIR /app
USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/nginx/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/nginx/run.sh" ]
