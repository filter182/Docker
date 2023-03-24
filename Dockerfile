FROM php:8.0.25-fpm-bullseye

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gd exif bcmath calendar FFI intl sockets sysvmsg sysvsem sysvshm redis excimer apcu bz2 gettext gmp igbinary imagick imap ldap memcached msgpack mysqli pdo_mysql pspell shmop soap tidy uuid xsl opcache zip

ENV WP_CLI_PACKAGES_DIR=/usr/local/wp-cli/packages/

COPY files/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY files/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY files/php.ini /usr/local/etc/php/php.ini

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install --no-install-recommends \
    aspell \
    bzip2 \
    ca-certificates \
    libfreetype6 libpng16-16 libjpeg62-turbo \
    gettext \
    git \
    libgmp10 \
    imagemagick \
    imagemagick-common \
    iputils-ping \
    less \
    curl \
    libldap-2.4-2 \
    libxml2 \
    libxslt1.1 \
    libzip4 \
    libmsgpackc2 \
    libev4 \
    libjemalloc2 \
    msmtp \
    msmtp-mta \
    openssh-client \
    pcre2-utils \
    tidy \
    unixodbc \
    zlib1g \
    libzstd1 \
    libkrb5-3 \
    libmemcached11 \
    libmemcachedutil2 \
    libc-client2007e \
    libgearman8 \
    libgssapi-krb5-2 \
    unzip \
    libfcgi-bin \
    sudo \
    ghostscript \
    libyaml-0-2 \
    subversion \
    libicu67 \
    libffi7 \
    mariadb-client-10.5 \
    libldap-common \
    && touch /etc/msmtprc \
    && chown 33:33 /etc/msmtprc \
    && chmod 600 /etc/msmtprc 

COPY --from=composer:1 --chown=0:0 /usr/bin/composer /usr/local/bin/composer
COPY --from=composer:2 --chown=0:0 /usr/bin/composer /usr/local/bin/composer2

RUN mkdir -p /usr/local/wp-cli/packages

RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar >  /tmp/wp-cli.phar \
    && chmod +x /tmp/wp-cli.phar \
    && mv /tmp/wp-cli.phar /usr/local/bin/wp \
    && /usr/local/bin/wp --allow-root package list 

RUN cd /usr/local/wp-cli/packages \
    && /usr/local/bin/composer2 --no-interaction require wp-cli/profile-command:@stable 
 
RUN /usr/local/bin/composer --no-interaction require wp-cli/doctor-command:@stable
    
    

CMD ["php-fpm"]
