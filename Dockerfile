FROM alpine:latest
LABEL maintainer "Fabricio Winter <git@notfab.net>"
ENV PROFTPD_VERSION 1.3.7c

# persistent / runtime deps
ENV PROFTPD_DEPS \
  g++ \
  gcc \
  libc-dev \
  make \
  mariadb-dev

RUN set -x \
    && apk add --no-cache --virtual .persistent-deps \
        ca-certificates \
        curl \
        mariadb-connector-c-dev \
        s6 \
    && apk add --no-cache --virtual .build-deps \
        $PROFTPD_DEPS \
    && curl -fSL ftp://ftp.proftpd.org/distrib/source/proftpd-${PROFTPD_VERSION}.tar.gz -o proftpd.tgz \
    && tar -xf proftpd.tgz \
    && rm proftpd.tgz \
    && mkdir -p /usr/local \
    && mv proftpd-${PROFTPD_VERSION} /usr/local/proftpd \
    && sleep 1 \
    && cd /usr/local/proftpd \
    && sed -i 's/__mempcpy/mempcpy/g' lib/pr_fnmatch.c \
    && ./configure --localstatedir=/run/proftpd --with-modules=mod_unique_id:mod_sql:mod_sql_mysql:mod_quotatab:mod_quotatab_sql:mod_sftp:mod_sftp_sql:mod_tls:mod_ratio:mod_copy:mod_deflate:mod_readme:mod_load --with-includes=/usr/include/mysql/ --enable-nls\
    && make \
    && cd /usr/local/proftpd && make install \
    && make clean \
    && apk del .build-deps

COPY s6 /etc/s6/
CMD ["/bin/s6-svscan", "/etc/s6"]
