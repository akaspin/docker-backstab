FROM frolvlad/alpine-glibc:alpine-3.5

RUN apk --no-cache add --virtual .buildpack curl libarchive-tools  && \
    curl -sSL https://releases.hashicorp.com/consul-template/0.18.0/consul-template_0.18.0_linux_amd64.zip | bsdtar -C /usr/bin/ -xvf- && \
    chmod +x /usr/bin/consul-template && \
    curl -sSL https://releases.hashicorp.com/consul/0.7.2/consul_0.7.2_linux_amd64.zip | bsdtar -C /usr/bin/ -xvf- && \
    chmod +x /usr/bin/consul && \
    curl -sSL https://get.docker.com/builds/Linux/x86_64/docker-1.13.0.tgz | tar xzv -C /tmp && \
    mv /tmp/docker/docker /usr/bin/docker && \
    rm -rf /tmp/docker && \
    apk del .buildpack

# Consul address and lock name
ENV BACKSTAB_CONSUL_ADDRESS 127.0.0.1:8500
ENV BACKSTAB_CONSUL_LOCK backstab

# Base64-encoded trigger consul template and initial delay
ENV BACKSTAB_TRIGGER 'Cg=='
ENV BACKSTAB_TIMEOUT 10m
ENV BACKSTAB_WINDOW 60s:120s

# Managed container and command
ENV BACKSTAB_CONTAINER sibling
ENV BACKSTAB_COMMAND restart
ENV BACKSTAB_DELAY 0

# Check health of managed container
ENV BACKSTAB_CHECK_HEALTH false
ENV BACKSTAB_CHECK_RETRIES 120
ENV BACKSTAB_CHECK_BACKOFF 5

ADD backstab-start.sh backstab-action.sh /usr/bin/

CMD /usr/bin/backstab-start.sh
