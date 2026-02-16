FROM serversideup/php:8.5-frankenphp

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    libsqlite3-dev \
    pkg-config \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_sqlite

WORKDIR /var/www/html
USER www-data

COPY --chown=www-data:www-data . .
COPY index.php .
COPY database ./database

RUN chown -R www-data:www-data /var/www/html/database

EXPOSE 80
