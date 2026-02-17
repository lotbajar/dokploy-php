FROM serversideup/php:8.5-frankenphp

# Switch to root for installation
USER root

# Install dependencies in a single layer with cleanup
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

# Set working directory
WORKDIR /var/www/html

# Copy composer files first for better layer caching (if you have them)
# COPY --chown=www-data:www-data composer.* ./
# RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy application files (exclude database directory initially)
COPY --chown=www-data:www-data --exclude=database --exclude=database.sqlite . .
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
# Copy database structure (migrations, seeders, factories)
COPY --chown=www-data:www-data database/ database/

# Ensure database directory exists and create SQLite file
RUN mkdir -p /var/www/html/database \
  && touch /var/www/html/database/app.sqlite \
  && chown -R www-data:www-data /var/www/html/database \
  && chmod 664 /var/www/html/database/app.sqlite \
  && chmod 775 /var/www/html/database

# Switch to non-root user for security
USER www-data

EXPOSE 8080
EXPOSE 8443
# Health check (optional but recommended)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Default command (FrankenPHP should have this set in base image)
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
