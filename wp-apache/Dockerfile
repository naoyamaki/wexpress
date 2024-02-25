FROM wordpress:6-php8.1-apache

ENV TZ Asia/Tokyo
RUN apt update

COPY custom.ini $PHP_INI_DIR/conf.d/

RUN sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/apache2/conf-available/security.conf
RUN sed -i 's/ServerSignature On/ServerSignature Off/g' /etc/apache2/conf-available/security.conf
