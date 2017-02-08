FROM frolvlad/alpine-glibc:alpine-3.5

RUN apk --no-cache add --virtual .buildpack curl libarchive-tools  && \
    curl -sSL https://releases.hashicorp.com/consul-template/0.18.1/consul-template_0.18.1_linux_amd64.zip | bsdtar -C /usr/bin/ -xvf- && \
    chmod +x /usr/bin/consul-template && \
    curl -sSL https://releases.hashicorp.com/consul/0.7.4/consul_0.7.4_linux_amd64.zip | bsdtar -C /usr/bin/ -xvf- && \
    chmod +x /usr/bin/consul && \
    curl -sSL https://get.docker.com/builds/Linux/x86_64/docker-1.13.0.tgz | tar xzv -C /tmp && \
    mv /tmp/docker/docker /usr/bin/docker && \
    rm -rf /tmp/docker && \
    apk del .buildpack

# Consul address and lock name
ENV CONSUL_HTTP_ADDR 127.0.0.1:8500
ENV BACKSTAB_CONSUL_LOCK backstab

# Base64-encoded trigger consul template
ENV BACKSTAB_TRIGGER 'Cg=='

# Restart routine timeout.
# This time must include time for all locks, delay after restart
# and time to healthcheck if enabled.
ENV BACKSTAB_TIMEOUT 30m

# Time window to ensure what trigger is stable. Use to avoid flapper.
ENV BACKSTAB_WINDOW 10m:30m

# Managed container ID/name and command to apply
ENV BACKSTAB_CONTAINER sibling
ENV BACKSTAB_COMMAND restart
# Delay after apply command on managed container
ENV BACKSTAB_DELAY 0

# Enable to wait for docker healthcheck
ENV BACKSTAB_CHECK_HEALTH false

# Healthcheck poll retries
ENV BACKSTAB_CHECK_RETRIES 120

# Healtcheck backoff time
ENV BACKSTAB_CHECK_BACKOFF 5

ADD backstab-start.sh backstab-action.sh /usr/bin/

CMD /usr/bin/backstab-start.sh
