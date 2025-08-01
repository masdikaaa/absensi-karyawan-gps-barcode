#!/bin/sh

cd /var/www

# Salin .env jika belum ada
[ ! -f .env ] && cp .env.example .env

# Install dependency PHP
composer install

# Generate app key jika belum ada
php artisan key:generate --ansi --force

# Jalankan migrasi dan seeder (opsional)
php artisan migrate --force || true
php artisan db:seed --force || true

# Permission folder runtime Laravel
mkdir -p storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Install npm & build assets
apt update && apt install -y npm
npm install
npm run build

# Jalankan perintah yang diberikan ke container
exec "$@"
