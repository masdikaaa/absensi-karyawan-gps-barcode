# ---------- Stage 1: Build Frontend with Node.js ----------
FROM node:20 AS node-builder

WORKDIR /var/www

COPY package.json package-lock.json ./
RUN npm install

COPY . .
RUN npm run build


# ---------- Stage 2: PHP with Composer ----------
FROM php:8.3-fpm

# Install PHP & system dependencies
RUN apt-get update && apt-get install -y \
    git zip unzip curl libzip-dev libpq-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy project & build assets
COPY --from=node-builder /var/www /var/www

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Buat .env jika belum ada, generate key, dan migrate
RUN cp .env.example .env && \
    php artisan key:generate --ansi --force && \
    php artisan migrate --force && \
    php artisan db:seed --force || true

# Set proper permissions
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
