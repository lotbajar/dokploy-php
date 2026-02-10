FROM php:8.3-apache

# Build deps voor PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev \
    pkg-config \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Enable sqlite extensions
RUN docker-php-ext-install pdo_sqlite sqlite3

WORKDIR /var/www/html
COPY index.php .
COPY database ./database

# Schrijfrechten voor SQLite file
RUN chown -R www-data:www-data /var/www/html/database

EXPOSE 80
