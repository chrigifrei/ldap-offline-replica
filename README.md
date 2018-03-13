# LDAP Offline Replication

Some tools have very limited LDAP caching support. To minimize latency we spin up a LDAP offline replica next to the desired app container (foobar, not part of this project).
The ldap-replica dumps the whole LDAP tree every `REPLICATION_INTERVAL` seconds.

Containers:

* ldap-replica: controls the ldap dump and spins up the ldap container
* ldap: controlled by ldap-replica; provides ldap service
* foobar: your app

## RUN

Set the LDAP BIND Password in the env and run docker-compose. The container evaluates the environment at startup (reading the `HOSTER` env var).

```bash
cd /path/to/docker-compose.yml
export LDAP_BIND_PW=<PASSWORD>
docker-compose up -d
unset LDAP_BIND_PW
```

Shutdown/Restart

```bash
cd /path/to/docker-compose.yml
docker-compose stop|down|restart
```

## BUILD

Configure `dockerbuild/replica/replicate.sh` according to your LDAP.

Build the image.

```bash
cd dockerbuild
docker build -t apontis.ch/ldap-replica:17.10-1.1 .
```
