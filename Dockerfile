FROM php:8.3-fpm

# Install system deps & PHP extensions
RUN apt-get update && apt-get install -y \
    git curl unzip zip supervisor nginx ffmpeg \
    libpng-dev libonig-dev libxml2-dev libzip-dev \
    libicu-dev g++ libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev libwebp-dev \
    libcurl4-openssl-dev pkg-config libssl-dev \
    libxslt1-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        exif \
        intl \
        bcmath \
        gd \
        zip \
        calendar \
        dom \
    && pecl install redis \
    && docker-php-ext-enable redis opcache

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install Node.js & npm (LTS version)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Copy configs
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini

# Set workdir
WORKDIR /var/www

# Copy project files
COPY . .

# Install PHP dependencies (optimize for production)
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Install frontend dependencies & build assets
RUN npm install && npm run build

# Fix permissions for Laravel/Bagisto
RUN mkdir -p /var/www/storage/logs \
    && chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Add extension check script
COPY ./docker/check-extensions.php /check-extensions.php

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]