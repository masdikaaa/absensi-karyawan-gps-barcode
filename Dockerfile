# ---------- Stage 1: Build Frontend with Node.js ----------
FROM node:20 AS node-builder

WORKDIR /var/www

COPY package.json package-lock.json ./
RUN npm install

COPY . .
RUN npm run build


# ---------- Stage 2: PHP with Composer ----------
FROM php:8.3-fpm

# Install PHP & system dependencies + extensions
RUN apt-get update && apt-get install -y \
    git zip unzip curl libzip-dev libpq-dev libonig-dev libxml2-dev libpng-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd bcmath

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Salin semua hasil dari stage node-builder
COPY --from=node-builder /var/www /var/www

# Copy dan buat file .env dari example
RUN cp .env.example .env

# Install dependensi Laravel & setup
RUN composer install --no-interaction --prefer-dist --optimize-autoloader && \
    php artisan key:generate --ansi --force && \
    php artisan migrate --force && \
    php artisan db:seed --force || true

# Set permissions Laravel
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]
