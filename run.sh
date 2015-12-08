#!/bin/bash

chown -R munin:www-data /var/lib/munin
chmod -R ug+rw          /var/lib/munin

cron

su - munin --shell=/bin/bash -c /usr/bin/munin-cron &

sed -i "s/^\[localhost\.localdomain\]/\[skynet\]/g" /etc/munin/munin.conf
munin-node-configure --remove --shell | sh
/usr/sbin/munin-node --config /etc/munin/munin-node.conf &

tail -F /var/log/munin/munin-update.log \
        /var/log/munin/munin-html.log \
        /var/log/munin/munin-cgi-graph.log \
        /var/log/munin/munin-cgi-html.log &

exec apache2ctl -DFOREGROUND
