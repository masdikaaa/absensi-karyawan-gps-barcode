#!/bin/sh

cd /var/www

[ ! -f .env ] && cp .env.example .env

composer install --no-interaction --prefer-dist --optimize-autoloader

php artisan key:generate --ansi --force
php artisan migrate --force
php artisan db:seed --force

npm install
npm run build

chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

exec "$@"
