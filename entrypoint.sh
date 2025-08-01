#!/bin/sh

cd /var/www

# Generate .env jika belum ada
[ ! -f .env ] && cp .env.example .env

# Install PHP dependencies
composer install --no-interaction --prefer-dist --optimize-autoloader

# Generate app key
php artisan key:generate --ansi --force

# Jalankan migrasi dan seeder
php artisan migrate --force
php artisan db:seed --force

# Install dan build frontend
npm install
npm run build

# ✅ FIX PERMISSION Laravel
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Jalankan php-fpm
exec "$@"
