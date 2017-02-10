FROM nginx:1.11.9
MAINTAINER Leandro Gomez<lgomez@devartis.com>

COPY andino.template /etc/nginx/conf.d/andino.template
COPY command.sh .

CMD ["bash", "command.sh"]