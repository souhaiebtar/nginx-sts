FROM alpine:3.2

MAINTAINER Souhaieb Tarhouni <tarhounisouhaieb@gmail.com>

ENV NGINX_VERSION nginx-1.15.3
ADD nginx.conf /nginx.conf
RUN apk --update add openssl-dev pcre-dev zlib-dev build-base curl unzip && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    curl -fLo ${NGINX_VERSION}.tar.gz  http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    curl -fLo nginx-module-sts.zip https://github.com/vozlt/nginx-module-sts/archive/master.zip && \
    curl -fLo nginx-module-stream-sts.zip https://github.com/vozlt/nginx-module-stream-sts/archive/master.zip && \
    unzip nginx-module-sts.zip && \
    unzip nginx-module-stream-sts.zip && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    cd /tmp/src/${NGINX_VERSION} && \
    ./configure \
        --with-stream \
        --with-http_ssl_module \
        --with-http_v2_module \
        --add-module=../nginx-module-sts-master \
        --add-module=../nginx-module-stream-sts-master \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx && \
    make && \
    make install && \
    mv -f /nginx.conf /etc/nginx/conf && \
    apk del build-base curl unzip && \
    rm -rf /tmp/src && \
    rm -rf /var/cache/apk/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]

WORKDIR /etc/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
