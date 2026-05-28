#!/bin/sh
set -e

php artisan migrate --force
php artisan storage:link || true
php artisan optimize
