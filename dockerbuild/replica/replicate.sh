#!/bin/sh

while true; do
    # get data from LDAP
    ldapsearch -x -LLL -h $LDAP_HOST \
        -w $(cat /etc/ldap-bind) \
        -D cn=admin,dc=apontis,dc=ch \
        -b "o=apontis" > /replica/dump.ldif
    
    # kill/rm old LDAP replica
    docker kill ldap
    docker rm ldap
    
    # start new LDAP replica
    docker run -d \
        --network ldapofflinereplication_sdn \
        -h ldap \
        -e LDAP_ORGANISATION="apontis" \
        -e LDAP_DOMAIN="apontis.ch" \
        -e LDAP_ADMIN_PASSWORD="admin" \
        -v /init.ldif:/init.ldif \
        -v /dump.ldif:/dump.ldif \
        --name=ldap osixia/openldap:1.1.9
    sleep 3

    ## populate LDAP data
    ldapadd -x -H ldap://ldap -D "cn=admin,dc=apontis,dc=ch" -w admin -f /replica/init.ldif
    ldapadd -x -H ldap://ldap -D "cn=admin,dc=apontis,dc=ch" -w admin -c -f /replica/dump.ldif

    #ldapsearch -x -H ldap://ldap -D "cn=admin,dc=apontis,dc=ch" -w admin

    sleep $REPLICATION_INTERVAL
done
