FROM ubuntu:trusty
MAINTAINER CodyWu <codewu@gmail.com> based on lamp from tutum.co

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor git apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Install openssh packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen
RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config








# Configure /app folder with sample app
RUN git clone https://github.com/fermayo/hello-world-lamp.git /app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
ENV AUTHORIZED_KEYS "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAmDjFuhYCpvWSXC4jdak+nU0jcG+Sybo03J5YHH9IoG/MmkTd3RT+HDb5WGuU5k7PFwMJ28/cCxvhiMQaC3rfNo6uPa7ftRLX5ORC5diOkYymy8WE2WjTdDTTOirGELS76HVd+WYJEXncPBfZ+hfOj3SvwtEl1f2dLcuIxKttu8C5h58Dmpp0FqmRdOnaohKeWZm7QK1mqiY2X+r/G2f0IKy5WbjPW/NbtjJMwrhzQErAY58SAZr0UOwYQ40NC4he1S+60yTgz7wn0GhBrzroBDaIXTI3mkVCRZTvFnkHkyxmUKUZdd6UZtW+/k+RCuLC4G8+5CwRMBOi1FzhSbECxw== rsa-key-20150815"


# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306 22
CMD ["/run.sh"]
CMD ["/sshrun.sh"]