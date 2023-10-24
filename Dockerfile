#
# amazon linux 2
# nginx 1.22.1
# node 10.24.1
#

FROM amazonlinux:2

# File Author / Maintainer
MAINTAINER ljay

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# update amazon software repo
RUN yum -y update \
	&& yum -y install shadow-utils \
	&& yum -y install tar unzip git bzip2

# nginx v1.x
RUN amazon-linux-extras enable nginx1 \
	&& yum -y install  \
    nginx \
    nginx-mod-http-geoip \
    nginx-mod-http-image-filter \
    nginx-mod-http-perl \
    nginx-mod-http-xslt-filter \
    nginx-mod-mail \
    nginx-mod-stream \
	&& nginx -v

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.24.1

RUN mkdir -p $NVM_DIR \
	&& curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash \
	&& . $NVM_DIR/nvm.sh \
	&& nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

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
