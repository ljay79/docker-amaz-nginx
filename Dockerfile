FROM amazonlinux:2018.03

# File Author / Maintainer
MAINTAINER ljay

# update amazon software repo
RUN yum -y update && yum -y install shadow-utils

# nginx 1.14.x
# Check if really required to install following mods
RUN yum install -y \
    nginx \
    nginx-mod-http-geoip \
    nginx-mod-http-image-filter \
    nginx-mod-http-perl \
    nginx-mod-http-xslt-filter \
    nginx-mod-mail \
    nginx-mod-stream

# Set UTC timezone
RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

# docker container usually wont add that file which is required by some init scripts
RUN echo "" >> /etc/sysconfig/network
RUN echo "upstream php-upstream { server php:9000; }" > /etc/nginx/conf.d/upstream.conf

# remove default vhost conf from package installation
RUN rm -f /etc/nginx/conf.d/virtual.conf

# cleanup
RUN yum clean all && rm -rf /tmp/* /var/tmp/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /var/www/html

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx"]
