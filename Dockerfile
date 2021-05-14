FROM centos:8
MAINTAINER madebymode

RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
    https://rpms.remirepo.net/enterprise/remi-release-8.rpm \
    yum-utils \ 
    && dnf module reset php \
    && dnf module install php:remi-8.0 -y \
    && dnf install -y php80-php-common php80-php-fpm php80 php80-php-cli php80-php \
    php80-php-gd php80-php-mysqlnd \
    mysql rsync wget \
    php-pecl-xdebug3

# Copy BH PHP ini
COPY etc/php.d/20-bh.ini /etc/php.d/20-bh.ini

# cheeseboard image processor
RUN wget -O wkhtmltox-0.12.6-1.centos8.x86_64.rpm https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox-0.12.6-1.centos8.x86_64.rpm \
    && dnf localinstall -y wkhtmltox-0.12.6-1.centos8.x86_64.rpm


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
