FROM postgres:9.5
MAINTAINER Jose A. Salgado<jose.salgado.wrk@gmail.com>

ENV POSTGRES_USER ckan
ENV POSTGRES_PASS ckan
ENV POSTGRES_DB ckan
ENV POSTGRES_PORT 5432

VOLUME ["/var/lib/postgresql/data/"]
EXPOSE $POSTGRES_PORT