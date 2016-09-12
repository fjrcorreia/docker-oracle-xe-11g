##
##  This image is a fork from:
##          https://github.com/wnameless/docker-oracle-xe-11g
##  Author:
##          Wei-Ming Wu <wnameless@gmail.com>

FROM ubuntu:16.04

MAINTAINER Francisco Correia

## Oracle
ENV NLS_LANG    American_America.WE8MSWIN1252

USER root

ADD assets /assets
RUN /assets/setup.sh

EXPOSE 1521
EXPOSE 8080

CMD ["/usr/sbin/startup.sh"]
