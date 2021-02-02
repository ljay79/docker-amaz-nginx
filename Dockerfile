FROM amazonlinux:2

# File Author / Maintainer
MAINTAINER ljay

# update amazon software repo
RUN yum -y update && yum -y install shadow-utils

# nginx v1.x
RUN amazon-linux-extras enable nginx1 \
	&& yum clean metadata \
	&& yum -y install \
    nginx \
    nginx-mod-http-geoip \
    nginx-mod-http-image-filter \
    nginx-mod-http-perl \
    nginx-mod-http-xslt-filter \
    nginx-mod-mail \
    nginx-mod-stream \
	&& nginx -v

# Set UTC timezone
#RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone

# docker container usually wont add that file which is required by some init scripts
RUN echo "upstream php-upstream { server php:9000; }" > /etc/nginx/conf.d/upstream.conf

# cleanup
RUN yum clean all && rm -rf /tmp/* /var/tmp/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /var/www/html

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx"]
