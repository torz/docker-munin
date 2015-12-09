#!/bin/bash
NODES=${NODES:-}

# generate node list
for NODE in $NODES
do
    NAME=`echo $NODE | cut -d ':' -f1`
    HOST=`echo $NODE | cut -d ':' -f2`
    cat << EOF >> /etc/munin/munin.conf
[$NAME]
    address $HOST
    use_node_name yes

EOF
done

echo "Using the following munin nodes:"
echo $NODES

touch /var/log/munin/munin-cgi-graph.log
touch /var/log/munin/munin-cgi-html.log
chown munin. /var/log/munin/munin-cgi-graph.log
chown munin. /var/log/munin/munin-cgi-html.log

chown munin. /var/lib/munin/

su - munin --shell=/bin/bash -c /usr/bin/munin-cron
spawn-fcgi -s /var/run/munin/fastcgi-graph.sock -U www-data -u munin -g munin /usr/lib/munin/cgi/munin-cgi-graph
spawn-fcgi -s /var/run/munin/fastcgi-html.sock  -U www-data -u munin -g munin /usr/lib/munin/cgi/munin-cgi-html

/usr/sbin/rsyslogd
/usr/sbin/cron

# show logs
echo 'Tailing /var/log/syslog and /var/log/munin/*'
tail -f /var/log/syslog /var/log/munin/* &

munin-node-configure --remove --shell | sh
/usr/sbin/munin-node --config /etc/munin/munin-node.conf &

nginx -g 'daemon off;'
