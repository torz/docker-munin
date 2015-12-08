FROM ubuntu:trusty

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apache2 \
        curl \
        ca-certificates \
        munin \
        munin-node \
        libwww-perl \
        cron \
        libapache2-mod-fcgid \
        libcgi-fast-perl && \
    apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN echo graph_strategy cgi >> /etc/munin/munin.conf && \
    echo html_strategy  cgi >> /etc/munin/munin.conf && \
    mkdir -p /var/run/munin && chown -R munin:munin /var/run/munin && \
    mkdir -p /var/log/munin && chown -R munin:munin /var/log/munin && \
    chown www-data:www-data /var/log/munin/munin-cgi*.log && \
    a2enmod rewrite && \
    a2enmod cgid && \
    a2disconf munin && \
    sed -ri 's/^log_file.*/# \0/; \
           s/^pid_file.*/# \0/; \
           s/^background 1$/background 0/; \
           s/^setsid 1$/setsid 0/; \
          ' /etc/munin/munin-node.conf && \
    /bin/echo -e "cidr_allow 192.168.0.0/16\ncidr_allow 172.16.0.0/12\ncidr_allow 10.0.0.0/8" >> /etc/munin/munin-node.conf

COPY apache.conf /etc/apache2/sites-enabled/000-default.conf
COPY run.sh /usr/local/bin/run

VOLUME /var/lib/munin
EXPOSE 80
CMD ["/usr/local/bin/run"]
