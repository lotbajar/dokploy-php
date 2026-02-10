FROM php:8.3-apache

RUN docker-php-ext-install pdo_sqlite sqlite3

WORKDIR /var/www/html
COPY index.php .
COPY database ./database

# Zorg dat Apache schrijfrechten heeft op de database
RUN chown -R www-data:www-data /var/www/html/database

EXPOSE 80