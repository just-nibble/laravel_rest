# PHP Images can be found at https://hub.docker.com/_/php/
FROM php:8.1-alpine

# The application will be copied in /home/application and the original document root will be replaced in the apache configuration
COPY . /home/application/

# Custom Document Root
ENV APACHE_DOCUMENT_ROOT /home/application/public

# Concatenated RUN commands
RUN apk add --update apache2 php-apache2 php-mbstring php-session php-json php-pdo php-openssl php-tokenizer php-pdo php-pdo_mysql php-xml php-simplexml\
    && chmod -R 777 /home/application/storage \
    && chown -R www-data:www-data /home/application \
    && mkdir -p /run/apache2 \
    && sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf \
    && sed -i '/LoadModule session_module/s/^#//g' /etc/apache2/httpd.conf \
    && sed -ri -e 's!/var/www/localhost/htdocs!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/httpd.conf \
    && sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/httpd.conf \
    && docker-php-ext-install pdo_mysql \
    && rm  -rf /tmp/* /var/cache/apk/*

# Launch the httpd in foreground
CMD rm -rf /run/apache2/* || true && /usr/sbin/httpd -DFOREGROUND
