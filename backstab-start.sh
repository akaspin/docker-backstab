#!/bin/sh

set -e

echo ${BACKSTAB_TRIGGER} | base64 -d > /trigger.tmpl

/usr/bin/consul-template -once -wait "${BACKSTAB_WINDOW}" -consul-addr=${BACKSTAB_CONSUL_ADDRESS} -template /trigger.tmpl:/trigger
cat > /consul.hcl <<-EOF
template {
    source = "/trigger.tmpl"
    destination = "/trigger"
    command = "/usr/bin/consul lock -verbose -http-addr=${BACKSTAB_CONSUL_ADDRESS} ${BACKSTAB_CONSUL_LOCK} /usr/bin/backstab-action.sh"
    command_timeout = "${BACKSTAB_TIMEOUT}"
}
EOF

echo "Running routine"
/usr/bin/consul-template -consul-addr=${BACKSTAB_CONSUL_ADDRESS} -wait "${BACKSTAB_WINDOW}" -config=/consul.hcl
