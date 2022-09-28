FROM php:8.0.22-fpm-bullseye

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gd exif bcmath calendar FFI intl sockets sysvmsg sysvsem sysvshm redis excimer apcu bz2 gettext gmp igbinary imagick imap ldap memcached msgpack mysqli pdo_mysql pspell shmop soap tidy uuid xsl opcache zip

COPY files/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY files/php-fpm.conf /usr/local/etc/php-fpm.conf

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install --no-install-recommends \
    msmtp \
    msmtp-mta \
    && touch /etc/msmtprc \
    && chown 33:33 /etc/msmtprc \
    && chmod 600 /etc/msmtprc 

COPY files/php.ini /usr/local/etc/php/php.ini

CMD ["php-fpm"]
