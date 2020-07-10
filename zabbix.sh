#!/bin/bash
apt install mc sudo git wget  -y
wget https://repo.zabbix.com/zabbix/5.0/debian/pool/main/z/zabbix-release/zabbix-release_5.0-1+buster_all.deb
dpkg -i zabbix-release_5.0-1+buster_all.deb
apt update -y
apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-agent -y
echo "stty -ixon" >> ~/bashrc
read -p "Введите пароль root для mysql: " rpass
read -p "Введите пароль для пользователя zabbix в mysql: " zpass
mysql -e "SET PASSWORD FOR root@localhost = PASSWORD('$rpass');FLUSH PRIVILEGES;" 
printf "$rpass\n n\n n\n n\n y\n y\n y\n" |  mysql_secure_installation
mysql -u root -p$rpass -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -u root -p$rpass -e "grant all privileges on zabbix.* to zabbix@localhost identified by '$zpass';"
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p$zpass zabbix
cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.bak
sed -i "s/Timeout=.*/Timeout=20/" /etc/zabbix/zabbix_server.conf
echo "DBHost=localhost" >> /etc/zabbix/zabbix_server.conf
echo "DBPassword=$zpass" >> /etc/zabbix/zabbix_server.conf
systemctl enable --now zabbix-server
git clone https://github.com/andrey0038/nginxconfig.git
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
rm /etc/nginx/nginx.conf
cp nginxconfig/nginx.conf /etc/nginx/nginx.conf
rm /etc/nginx/sites-enabled/default
cp /etc/nginx/conf.d/zabbix.conf /etc/nginx/sites-available/zabbix.conf
ln -s /etc/nginx/sites-available/zabbix.conf /etc/nginx/sites-enabled/zabbix.conf
echo "php_value[date.timezone] = Asia/Almaty" >> /etc/zabbix/php-fpm.conf
systemctl restart nginx php7.3-fpm
systemctl enable nginx php7.3-fpm