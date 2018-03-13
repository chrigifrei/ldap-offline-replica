FROM docker:17.10

LABEL description="LDAP Offline Replica"

ENV REPLICATION_INTERVAL="3600"

RUN apk --update add openldap-clients

ADD replica /replica

ENTRYPOINT ["/replica/docker-entrypoint.sh"]
