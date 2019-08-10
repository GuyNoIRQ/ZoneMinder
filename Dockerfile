FROM debian
EXPOSE 80/tcp
COPY SecureSql.sql SecureSql.sql
COPY DBPerms.sql DBPerms.sql  
COPY StartUp.sh StartUp.sh

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y wget && \
    wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb && \
    dpkg -i deb-multimedia-keyring_2016.8.1_all.deb && \
    echo "deb http://www.deb-multimedia.org buster main non-free" >> /etc/apt/sources.list && \
    rm deb-multimedia-keyring_2016.8.1_all.deb && \
    apt-get update && \
    apt-get install -y apache2 curl net-tools mariadb-server php libapache2-mod-php php-mysql vim

RUN service mysql start && \
    sleep 1 && \
    mysql -sfu root < "SecureSql.sql"

RUN apt-get install -y zoneminder vlc-plugin-base

RUN service mysql start && \
    sleep 1 && \
    mysql -sfu root < /usr/share/zoneminder/db/zm_create.sql && \
    mysql -sfu root < "DBPerms.sql" && \
    mysqladmin -u root reload

RUN chmod 740 /etc/zm/zm.conf && \
    chown root:www-data /etc/zm/zm.conf && \
    chown -R www-data:www-data /usr/share/zoneminder/

RUN a2enmod cgi && \
    a2enmod rewrite && \
    a2enconf zoneminder && \
    a2enmod expires && \
    a2enmod headers && \
    sed -i 's/;date.timezone =/date.timezone = America\/New_York/g' /etc/php/7.3/apache2/php.ini && \
    service mysql start && \
    sleep 1 && \
    service apache2 restart && \
    service zoneminder restart && \
    sleep 5 

ENTRYPOINT ["/StartUp.sh"]
