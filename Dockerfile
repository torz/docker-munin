FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
# Update.
RUN \
    apt-get -q update && \
    apt-get install -y \
        munin \
        munin-node \
        cron nginx \
        spawn-fcgi \
        libcgi-fast-perl && \
        apt-get clean && \
        rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Configure as cgi.
RUN \
    sed -i 's/^#graph_strategy cron/graph_strategy cgi/g' /etc/munin/munin.conf && \
    sed -i 's/^#html_strategy cron/html_strategy cgi/g' /etc/munin/munin.conf && \
    sed -i 's/^\[localhost\.localdomain\]/#\[localhost\.localdomain\]/g' /etc/munin/munin.conf && \
    sed -i 's/^    address 127.0.0.1/#    address 127.0.0.1/g' /etc/munin/munin.conf && \
    sed -i 's/^    use_node_name yes/#    use_node_name yes/g' /etc/munin/munin.conf

# Create munin dirs.
RUN \
    mkdir -p /var/run/munin && \
    chown -R munin:munin /var/run/munin

ADD run.sh /usr/local/bin/start-munin
ADD nginx.conf /etc/nginx/sites-available/default

VOLUME /var/lib/munin
VOLUME /var/log/munin
VOLUME /etc/munin

EXPOSE 80
CMD ["start-munin"]
