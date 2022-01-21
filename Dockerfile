FROM centos:8
MAINTAINER madebymode

# update dnf
RUN dnf -y update
RUN dnf -y install dnf-utils
RUN dnf clean all

# install epel-release
RUN dnf -y install epel-release


# install remi repo
RUN dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm

RUN dnf -y install yum-utils \ 
    && dnf module install php:remi-8.0 -y \
    && dnf install -y php80-php-common php80-php-fpm php80 php80-php-cli php80-php \
    php80-php-gd php80-php-mysqlnd \
    mysql rsync wget git \
    php-pecl-xdebug3

# Copy BH PHP ini
COPY etc/php.d/20-bh.ini /etc/php.d/20-bh.ini

# Update and install latest packages and prerequisites
RUN dnf update -y \
    && dnf install -y --nogpgcheck --setopt=tsflags=nodocs \
        zip \
        unzip \
    && dnf clean all && dnf history new

RUN curl -sS https://getcomposer.org/installer | php --  --install-dir=/usr/local/bin --filename=composer

RUN sed -e 's/\/run\/php\-fpm\/www.sock/9000/' \
        -e '/allowed_clients/d' \
        -e '/catch_workers_output/s/^;//' \
        -e '/error_log/d' \
        -i /etc/php-fpm.d/www.conf

RUN mkdir /run/php-fpm

CMD ["php-fpm", "-F"]

EXPOSE 9000
