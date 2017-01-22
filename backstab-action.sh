#!/bin/sh

echo "Apply ${BACKSTAB_COMMAND} to ${BACKSTAB_CONTAINER}"
/usr/bin/docker ${BACKSTAB_COMMAND} ${BACKSTAB_CONTAINER}

echo "Delaying ${BACKSTAB_DELAY}"
sleep ${BACKSTAB_DELAY}

if ${BACKSTAB_CHECK_HEALTH}
then
    echo "Waiting for ${BACKSTAB_CONTAINER} health check"
    for i in $(seq 0 ${BACKSTAB_CHECK_RETRIES}); do
        echo "Attempt ${i}"
        sleep ${BACKSTAB_CHECK_BACKOFF}
        if [ $(/usr/bin/docker inspect -f '{{ .State.Health.Status }}' ${BACKSTAB_CONTAINER}) == "healthy" ]
        then
            echo "Container ${BACKSTAB_CONTAINER} is healthy"
            exit 0
        fi
    done
    echo "Giving-up"
fi
exit 0
echo "Action complete"
