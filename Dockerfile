FROM nginx:stable-alpine

ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/service.conf /etc/nginx/service.conf
ADD script/entrypoint.sh /entrypoint.sh

#acme.sh doesn't work with wget from busybox, so must install it additionally
#wget is chosen instead of curl because of size (curl has dependencies)
RUN apk --no-cache add -f \
    openssl \
    coreutils \
    wget \
    tzdata

#install acme.sh
RUN set -o pipefail && \
    wget -O - https://raw.githubusercontent.com/Neilpang/acme.sh/master/acme.sh | INSTALLONLINE=1 sh && \
    ln -s /root/.acme.sh/acme.sh /usr/local/bin/acme.sh

CMD ["/entrypoint.sh"]