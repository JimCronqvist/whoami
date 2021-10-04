FROM alpine:3.14

# Install packages
RUN apk --no-cache --update add \
    bash \
    curl \
    ca-certificates \
    openssl \
    apache2 \
    apache2-ssl \
    php8-apache2 \
    php8-phar \
    php8-json \
    php8-iconv \
    php8-openssl \
    php8-mbstring

# Generate new dummy certs to avoid errors
RUN openssl genrsa -out /etc/ssl/apache2/server.key 2048 && \
    openssl req -new -out /etc/ssl/apache2/server.csr -subj "/C=US/ST=N\/A/L=Self-Signed/O=Test/CN=whoami" -sha256 -key /etc/ssl/apache2/server.key && \
    openssl x509 -req -in /etc/ssl/apache2/server.csr -days 365 -signkey /etc/ssl/apache2/server.key -out /etc/ssl/apache2/server.pem -outform PEM

# Symlink the php executable
RUN ln -s /usr/bin/php8 /usr/bin/php

# Add Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Modify apache config
RUN sed -i "s/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#ServerName\ www.example.com:80/ServerName\ whoami/" /etc/apache2/httpd.conf \
    && sed -i 's#^DocumentRoot ".*#DocumentRoot "/app"#g' /etc/apache2/httpd.conf \
    && sed -i 's#Directory "/var/www/localhost/htdocs"#Directory "/app"#g' /etc/apache2/httpd.conf \
    && sed -i 's#^ErrorLog .*#ErrorLog "/dev/stderr"\nTransferLog "/dev/stdout"#g' /etc/apache2/httpd.conf \
    && sed -i 's#CustomLog .* combined#CustomLog "/dev/null" combined#g' /etc/apache2/httpd.conf \
    && sed -i "s#^LogLevel .*#LogLevel notice#g" /etc/apache2/httpd.conf \
    && sed -i 's#^DocumentRoot ".*#DocumentRoot "/app"#g' /etc/apache2/conf.d/ssl.conf \
    && sed -i "s/ServerName\ www.example.com:443/ServerName\ whoami/" /etc/apache2/conf.d/ssl.conf \
    && sed -i 's#^ErrorLog .*#ErrorLog "/dev/stderr"#g' /etc/apache2/conf.d/ssl.conf \
    && sed -i 's#^CustomLog logs/ssl_request.log#CustomLog "/dev/null"#g' /etc/apache2/conf.d/ssl.conf \
    && sed -i 's#^TransferLog .*#TransferLog "/dev/stdout"#g' /etc/apache2/conf.d/ssl.conf

# Add Directory in apache2 + enable rewrite
RUN    echo ''                                >> /etc/apache2/httpd.conf \
    && echo '<Directory "/app">'              >> /etc/apache2/httpd.conf \
    && echo '    AllowOverride All'           >> /etc/apache2/httpd.conf \
    && echo '    RewriteEngine On'            >> /etc/apache2/httpd.conf \
    && echo '    RewriteRule ^ index.php [L]' >> /etc/apache2/httpd.conf \
    && echo '</Directory>'                    >> /etc/apache2/httpd.conf \
    && echo ''                                >> /etc/apache2/httpd.conf

# Create the dir for the application
RUN mkdir /app

# Change the working directory & user
WORKDIR /app

# Install dependency
RUN composer require --update-no-dev --prefer-install dist symfony/http-foundation

# Add the code
COPY index.php .

# Expose http & https ports
EXPOSE 80 443

#CMD ["sleep", "infinity"]
CMD ["httpd", "-D", "FOREGROUND"]