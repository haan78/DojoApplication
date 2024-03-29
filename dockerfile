FROM php:7.4.3-apache as base


RUN apt-get update 
RUN apt-get -y install \    
    libpng-dev \
    libwebp-dev \    
    libjpeg62-turbo-dev \
    libpng-dev libxpm-dev \
    libfreetype6-dev \
	libxml2-dev \
    git \
    zip \
    unzip \
    libmcrypt-dev \
    zlib1g-dev \
    libzip-dev \
    libonig-dev \
    graphviz \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev

RUN apt-get -y install libjpeg-dev

RUN docker-php-ext-install mbstring
RUN docker-php-ext-install exif

RUN docker-php-ext-install mysqli
RUN docker-php-ext-install soap
RUN docker-php-ext-install zip


RUN docker-php-ext-configure gd --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd
RUN echo "upload_max_filesize = 100M" > $PHP_INI_DIR/conf.d/upload.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY ./secrets.json /etc/.secrets/dojo.json
RUN chmod 755 -R /etc/.secrets
WORKDIR /var/www/html

FROM base as production
COPY ./html /var/www/html
RUN composer install
ENTRYPOINT [ "apache2-foreground" ]