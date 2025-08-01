#!/bin/sh

cd /var/www

# Salin .env jika belum ada
[ ! -f .env ] && cp .env.example .env

# Install dependency PHP
composer install --no-interaction --prefer-dist --optimize-autoloader

# Generate app key jika belum ada
php artisan key:generate --ansi --force

# Jalankan migrasi dan seeder (opsional)
php artisan migrate --force || true
php artisan db:seed --force || true

# Build frontend Laravel 11 (Vite + Tailwind)
npm install
npm run build

# Permission folder runtime Laravel
mkdir -p storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

exec "$@"
