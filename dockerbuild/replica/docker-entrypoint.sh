#!/bin/sh

export REPLICATION_INTERVAL=${REPLICATION_INTERVAL:-3600}

echo $LDAP_BIND_PW > /etc/ldap-bind
chmod 600 /etc/ldap-bind
unset LDAP_BIND_PW

pid=0

# custom signal handler, since SIGKILL is not handled properly
# make sure you add 'stop_signal: SIGUSR1' to your docker-compose.yml
my_handler() {
    echo "terminating ldap..."
    docker kill ldap
    docker rm ldap
    kill -SIGKILL "$pid"
}

# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; my_handler' SIGUSR1
trap 'kill ${!}; my_handler' SIGKILL

# run application
/bin/sh /replica/replicate.sh &
pid="$!"

# wait indefinitely
# we cannot use sleep here, since sleep ignores signals
while true
do
    tail -f /dev/null & wait ${!}
done