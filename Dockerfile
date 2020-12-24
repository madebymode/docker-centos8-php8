FROM centos:8
MAINTAINER madebymode

RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    https://rpms.remirepo.net/enterprise/remi-release-8.rpm \
    yum-utils \ 
    && dnf module reset php \
    && dnf module install php:remi-8.0 -y \
    && dnf install -y php80-php-common php80-php-fpm php80 php80-php-cli php80-php  php80-php-gd

# Update and install latest packages and prerequisites
RUN dnf update -y \
    && dnf install -y --nogpgcheck --setopt=tsflags=nodocs \
        zip \
        unzip \
    && dnf clean all && dnf history new

RUN curl -sS https://getcomposer.org/installer | php -- --version=1.10.17 --install-dir=/usr/local/bin --filename=composer

RUN sed -e 's/\/run\/php\-fpm\/www.sock/9000/' \
        -e '/allowed_clients/d' \
        -e '/catch_workers_output/s/^;//' \
        -e '/error_log/d' \
        -i /etc/php-fpm.d/www.conf

RUN mkdir /run/php-fpm

CMD ["php-fpm", "-F"]

EXPOSE 9000
