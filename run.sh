#!/bin/bash
set -x
CONSUL_JOIN=$(ip r g 8.8.8.8 | awk '{ gsub(/\n$/,""); printf("%s", $3); }')
POSTGRESQL_USER=${POSTGRESQL_USER:-"docker"}
POSTGRESQL_PASS=${POSTGRESQL_PASS:-"docker"}
POSTGRESQL_DB=${POSTGRESQL_DB:-"docker"}
POSTGRESQL_TEMPLATE=${POSTGRESQL_TEMPLATE:-"DEFAULT"}

POSTGRES_ROOTUSER=${POSTGRESQL_ROOTUSER:-"postgres"}
POSTGRES_ROOTPASS=${POSTGRESQL_ROOTPASS:-"J8fwwzeMQvmDRKg"}
POSTGRES_HOST=${POSTGRESQL_HOST:-"postgres.node.consul"}
export PGPASSWORD=$POSTGRES_ROOTPASS

POSTGRESQL_BIN=/usr/lib/postgresql/9.3/bin/postgres
POSTGRESQL_CONFIG_FILE=/etc/postgresql/9.3/main/postgresql.conf
POSTGRESQL_DATA=/var/lib/postgresql/9.3/main

#POSTGRESQL_SINGLE="sudo -u postgres $POSTGRESQL_BIN --single --config-file=$POSTGRESQL_CONFIG_FILE"
POSTGRESQL_SINGLE="psql -h $POSTGRES_HOST -w -U $POSTGRES_ROOTUSER"

DATACENTRE=${DATACENTRE:-"default"}
ENCRYPT=${ENCRYPT:-"Ka33LTg+OADO9G1W2+4REQ=="}

# Wait for postgres to come up
until nc -vzw 2 $POSTGRES_HOST 5432; do sleep 2; done

#if [ ! -d $POSTGRESQL_DATA ]; then
#    mkdir -p $POSTGRESQL_DATA
#    chown -R postgres:postgres $POSTGRESQL_DATA
#    sudo -u postgres /usr/lib/postgresql/9.3/bin/initdb -D $POSTGRESQL_DATA -E 'UTF-8'
#    ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem $POSTGRESQL_DATA/server.crt
#    ln -s /etc/ssl/private/ssl-cert-snakeoil.key $POSTGRESQL_DATA/server.key
#fi

$POSTGRESQL_SINGLE <<< "CREATE USER $POSTGRESQL_USER WITH SUPERUSER;" > /dev/null
$POSTGRESQL_SINGLE <<< "ALTER USER $POSTGRESQL_USER WITH PASSWORD '$POSTGRESQL_PASS';" > /dev/null
$POSTGRESQL_SINGLE <<< "CREATE DATABASE $POSTGRESQL_DB OWNER $POSTGRESQL_USER TEMPLATE $POSTGRESQL_TEMPLATE;" > /dev/null

#exec sudo -u postgres $POSTGRESQL_BIN --config-file=$POSTGRESQL_CONFIG_FILE &

# Get the licence into the instance
#while ! curl --fail -u admin:password -X POST -H "Content-Type: application/json" -d '{"licenseKey": "jb12tcBe1seX6ygwcozB4dBgY0LDP0IWUrKFAkV5ZeJFbZfKFUJO1CHhyFgx3LqX/adeE0ane58S vIL0o+5ObDV1uXCoQneXeh5591Im0N0admyNO+C8r3z+i1n/CeGO4NC38gwMkTDMHqUuJqOoYxgR HdijBItwJbshFkrpaWLlepTkM3WDau6kddscODAhTT1ydkflXi9OG41uwYxypPgar2SrjI0vL/M+ kbxTASS+g6ovu0GlwnanQpF2uc0cTGrj3Uz5JueUIy7yvamd1sfrP4dKHrrD9eQQNcUvXZpfatyN rtO8zzV6qwAjxnf3J1TiaIAEbwYOkFU2R45owI0sRMDJ+xZZzw7LqpdGmx7emkhcFlA5855N/0vj o0ASPnquE9CdTTQIQXtBWV8En1AJ01o6FKZ/qsG/GBl4LBWPKEJ6O3MiBeomjXkDylHIVUZL7DoN akf0nNbjgKpno5l1FuAprgg28V6CyuRw5mCQYnosh+Go3bct50/5eRRVeAg9GJrTAs/xHIeiVuhw UrznX880QtD6yVj+IHyV/U2C+cwxwgr+zoZWh2Um/FbKj9plZ3007/lUquKDZHq3tMgGx5fRVD1U DriY8GA+DKdBlNzL+IPvQb9DBC8JjdccHzac+yVzIzRRedMUXxxSHo+NA931P2AGdEqxsYKy7ERO ZMVC7RYmVgay3kignPQQrocUL2taiePTwpOdcnLkKZNW0i0pzT5y0CkVb30qzORkAQcb+oPilz6K +cjtjQRH8JMsHlHvHbh8rvGbzSoqh1CgvjQTTI1r"}' http://127.0.0.1:8080/artifactory/api/system/license ; 
#  do echo "wating for artifactory to become available" && sleep 10 ; done &
#
if [ ! -f /.tomcat_admin_created ]; then
    /create_tomcat_admin_user.sh
fi

exec /usr/local/bin/consul agent -data-dir /consul-data -config-dir /etc/consul.d -join $CONSUL_JOIN -dc $DATACENTRE -client 0.0.0.0 -encrypt ${ENCRYPT} &
exec ${CATALINA_HOME}/bin/catalina.sh run


