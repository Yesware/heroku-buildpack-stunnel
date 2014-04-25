#!/usr/bin/env bash

n=1

mkdir -p /app/vendor/stunnel/var/run/stunnel/
echo "$STUNNEL_PEM" > /app/vendor/stunnel/stunnel.pem
cat >> /app/vendor/stunnel/stunnel.conf << EOFEOF
foreground = yes
cert=/app/vendor/stunnel/stunnel.pem
key=/app/vendor/stunnel/stunnel.pem
options = NO_SSLv2
options = SINGLE_ECDH_USE
options = SINGLE_DH_USE
socket = r:TCP_NODELAY=1
options = NO_SSLv3
ciphers = HIGH:!ADH:!AECDH:!LOW:!EXP:!MD5:!3DES:!SRP:!PSK:@STRENGTH
EOFEOF

for STUNNEL_URL in $STUNNEL_URLS
do
  eval STUNNEL_URL_VALUE=\$$STUNNEL_URL
  #TODO: Generalize away that "redis" bit in the next line
  DB=$(echo $STUNNEL_URL_VALUE | perl -lne 'print "$1 $2 $3 $4 $5 $6 $7" if /^redis:\/\/([^:]+):([^@]+)@(.*?):(.*?)\/(.*?)(\\?.*)?$/')
  DB_URI=( $DB )
  DB_USER=${DB_URI[0]}
  DB_PASS=${DB_URI[1]}
  DB_HOST=${DB_URI[2]}
  DB_PORT=${DB_URI[3]}
  DB_NAME=${DB_URI[4]}

  echo "Setting ${STUNNEL_URL}_STUNNEL config var"

  export ${STUNNEL_URL}_STUNNEL=redis://$DB_USER:$DB_PASS@127.0.0.1:600${n}/$DB_NAME

  cat >> /app/vendor/stunnel/stunnel.conf << EOFEOF
[$STUNNEL_URL]
client = yes
accept = 600${n}
connect = $DB_HOST:$DB_PORT
EOFEOF

  let "n += 1"
done

chmod go-rwx /app/vendor/stunnel/*
