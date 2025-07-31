FROM php:8.3-fpm

# Install system & PHP dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev \
    gnupg ca-certificates wget \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Install Node.js & npm (Node 20)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node -v && npm -v

# Install Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy all project files
COPY . .

# Install PHP (Laravel) dependencies
RUN composer install --no-dev --optimize-autoloader \
    && chmod -R 775 storage bootstrap/cache

# Install frontend dependencies & build assets
RUN npm install && npm run build
