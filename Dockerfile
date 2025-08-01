# ---------- Stage 1: Prepare Node Modules ----------
FROM node:20 AS node-deps

WORKDIR /var/www

COPY package.json package-lock.json ./
RUN npm install


# ---------- Stage 2: Final PHP-FPM with Laravel ----------
FROM php:8.3-fpm

# Install PHP & system dependencies + extensions
RUN apt-get update && apt-get install -y \
    git zip unzip curl libzip-dev libpq-dev libonig-dev libxml2-dev libpng-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd bcmath

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

<<<<<<< HEAD
WORKDIR /var/www

# Salin semua hasil dari stage node-builder
COPY --from=node-builder /var/www /var/www

# Install dependensi Laravel & setup
RUN composer install --no-interaction --prefer-dist --optimize-autoloader && \
    php artisan key:generate --ansi --force && \
    php artisan migrate --force && \
    php artisan db:seed --force || true
=======
# Set workdir
WORKDIR /var/www

# Copy full project code
COPY . .

# Copy installed node_modules from previous stage
COPY --from=node-deps /var/www/node_modules ./node_modules

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
>>>>>>> 562b2b3 (Update Code)

# Set permissions Laravel
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

EXPOSE 9000
<<<<<<< HEAD
=======

ENTRYPOINT ["entrypoint.sh"]
>>>>>>> 562b2b3 (Update Code)
CMD ["php-fpm"]
