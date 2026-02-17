FROM serversideup/php:8.4-fpm-nginx

ENV PHP_OPCACHE_ENABLE=1

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends libsqlite3-dev \
    && docker-php-ext-install pdo_sqlite \
    && apt-get purge -y libsqlite3-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
USER www-data

WORKDIR /var/www/html

COPY --chown=www-data:www-data index.php .
COPY --chown=www-data:www-data database ./database

EXPOSE 80
