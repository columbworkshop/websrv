FROM php:7.4-fpm

# install packets
RUN apt-get update && apt-get install -y cron nano iputils-ping curl 

# install php-extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync 

# install-php-extensions

RUN install-php-extensions imagick amqp apcu bcmath exif gd grpc imap intl ldap mysqli mcrypt opcache pgsql \ 
                           pdo_pgsql sockets uuid xdebug yaml zip xsl pdo_mysql
# install php composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# copy crobjobs
COPY cronjobs /etc/cron.d/cronjobs

# add permissions
RUN chmod 0644 /etc/cron.d/cronjobs

# Apply cron job
RUN crontab /etc/cron.d/cronjobs

# Run cron on container startup
#RUN cron




