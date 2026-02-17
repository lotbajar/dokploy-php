FROM serversideup/php:8.4-frankenphp

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    libsqlite3-dev \
    pkg-config \
    ca-certificates \
  && docker-php-ext-install pdo_sqlite \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

WORKDIR /var/www/html

# Copy app excluding the SQLite database file itself
COPY --chown=www-data:www-data . .

# Ensure the SQLite file exists with correct permissions
RUN mkdir -p /var/www/html/database \
  && touch /var/www/html/database/app.sqlite \
  && chown -R www-data:www-data /var/www/html/database \
  && chmod 664 /var/www/html/database/app.sqlite \
  && chmod 775 /var/www/html/database

USER www-data

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
