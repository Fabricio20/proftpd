FROM alpine:3.14
MAINTAINER Fabricio Winter <git@notfab.net>

RUN ["/bin/sh", "-c", "apk --no-cache upgrade && apk --no-cache add s6 proftpd proftpd-mod_sql_mysql proftpd-mod_quotatab_sql proftpd-mod_tls_shmcache"]
COPY s6 /etc/s6/

CMD ["/bin/s6-svscan", "/etc/s6"]
