FROM ubuntu:14.04
MAINTAINER Jose A. Salagdo<jose.salgado.wrk@gmail.com>


# Actualizamos las bases de apt-get!
RUN apt-get -qqy update 

RUN apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get update

# Instalamos la Herramientas que vamos a requerir
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install \
            libevent-dev \
            libpq-dev \
            build-essential \
            python-dev \
            python-minimal \
            python-virtualenv \
            python-pip \
            wget \
            nano \
            nmap \
            git-core

# ENV Vars.. 
ENV HOME /root