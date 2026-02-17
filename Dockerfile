FROM serversideup/php:8.4-fpm-nginx

ENV PHP_OPCACHE_ENABLE=1

USER root
RUN docker-php-ext-install pdo_sqlite
USER www-data

WORKDIR /var/www/html

COPY --chown=www-data:www-data index.php .
COPY --chown=www-data:www-data database ./database

EXPOSE 80
