#!/usr/bin/with-contenv /bin/bash
set -e
sed -e "s/{{LISTEN_PORT}}/$PORT/g" /etc/nginx/conf.d/app.conf.template > /etc/nginx/conf.d/app.conf
exec /usr/sbin/nginx
