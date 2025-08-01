# ---------- Stage: PHP-FPM with Laravel + Node.js ----------
FROM php:8.3-fpm

# Install PHP & system dependencies + extensions
RUN apt-get update && apt-get install -y \
    git zip unzip curl libzip-dev libpq-dev libonig-dev libxml2-dev libpng-dev gnupg \
    && docker-php-ext-install pdo pdo_mysql zip gd bcmath

# Install Node.js 20.x & npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set workdir
WORKDIR /var/www

# Copy full project code
COPY . .

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Buka port PHP-FPM
EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
