#!/bin/sh

set -e

echo ${BACKSTAB_TRIGGER} | base64 -d > /trigger.tmpl

echo "Delaying ${BACKSTAB_INITIAL_DELAY}"
sleep ${BACKSTAB_INITIAL_DELAY}


/usr/bin/consul-template -once -consul-addr=${BACKSTAB_CONSUL_ADDRESS} -template /trigger.tmpl:/trigger
cat > /consul.hcl <<-EOF
template {
    source = "/trigger.tmpl"
    destination = "/trigger"
    command = "/usr/bin/consul lock -verbose -http-addr=${BACKSTAB_CONSUL_ADDRESS} ${BACKSTAB_CONSUL_LOCK} /usr/bin/backstab-action.sh"
    command_timeout = "${BACKSTAB_TIMEOUT}"
    wait = "${BACKSTAB_TIMEOUT}"
}
EOF

echo "Running routine"
/usr/bin/consul-template -consul-addr=${BACKSTAB_CONSUL_ADDRESS} -config=/consul.hcl
