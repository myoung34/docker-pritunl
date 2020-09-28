#!/bin/bash
set -e

[ -d /dev/net ] || mkdir -p /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200

touch /var/log/pritunl.log
touch /var/run/pritunl.pid
/bin/rm /var/run/pritunl.pid

export PRITUNL_LOG_FILE=${PRITUNL_LOG_FILE:-"/var/log/pritunl.log"}
export PRITUNL_DEBUG=${PRITUNL_DEBUG:-"false"}
export PRITUNL_BIND_ADDR=${PRITUNL_BIND_ADDR:-"0.0.0.0"}

cat << EOF >/etc/pritunl.conf
{
    "mongodb_uri": "$PRITUNL_MONGODB_URI",
    "server_key_path": "/var/lib/pritunl/pritunl.key",
    "log_path": "$PRITUNL_LOG_FILE",
    "static_cache": true,
    "server_cert_path": "/var/lib/pritunl/pritunl.crt",
    "temp_path": "/tmp/pritunl_%r",
    "bind_addr": "$PRITUNL_BIND_ADDR",
    "debug": $PRITUNL_DEBUG,
    "www_path": "/usr/share/pritunl/www",
    "local_address_interface": "auto"
}
EOF

# shellcheck disable=SC2015
[[ -n "$NO_LOG_FILE" ]] && ( sed -i.bak 's/.log_path.*//g' /etc/pritunl.conf; sed -i.bak 's/.journal_path.*//g' /etc/pritunl.conf ) || :

exec /usr/bin/pritunl start -c /etc/pritunl.conf
