# Use PHP 8.1 FPM with Apache
FROM php:8.1-fpm-alpine

# Install required dependencies
RUN apk add --no-cache \
    nginx \
    curl \
    git \
    zip \
    unzip \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-libs \
    icu-dev \
    supervisor \
    zlib-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql intl

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html/

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --prefer-dist --no-interaction 

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Copy NGINX configuration
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# Allow dynamic Nginx port configuration
RUN sed -i "s,LISTEN_PORT,$PORT,g" /etc/nginx/http.d/default.conf

# Copy Supervisor configuration
COPY docker/supervisord.conf /etc/supervisord.conf

# Expose ports dynamically
EXPOSE ${PORT}

# Start services using Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
