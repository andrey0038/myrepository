#!/bin/bash
apt update -y && apt upgrade -y
apt install mc sudo git wget unzip  -y
apt install nginx php php-cli php-xml php-mbstring php-mysql php7.3-fpm -y
sed -i "s/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/" /etc/php/7.3/fpm/php.ini
git clone https://github.com/andrey0038/nginxconfig.git
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
rm /etc/nginx/nginx.conf
cp nginxconfig/nginx.conf /etc/nginx/nginx.conf
systemctl reload nginx
systemctl reload php7.3-fpm
apt install -y mariadb-server -y
echo "stty -ixon" >> ~/bashrc
read -p "Введите пароль root для mysql: " rpass
read -p "Введите пароль для пользователя glpi в mysql: " gpass
mysql -e "SET PASSWORD FOR root@localhost = PASSWORD('$rpass');FLUSH PRIVILEGES;" 
printf "$rpass\n n\n n\n n\n y\n y\n y\n" |  mysql_secure_installation
apt install php7.3 php7.3-curl php7.3-zip php7.3-gd php7.3-intl php-pear php-imagick php7.3-imap php-memcache php7.3-pspell php7.3-recode php7.3-tidy php7.3-xmlrpc php7.3-xsl php7.3-mbstring php-gettext php7.3-ldap php-cas php-apcu php7.3-mysql php7.3-fpm -y
sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php/7.3/fpm/pool.d/www.conf
mysql -u root -p$rpass -e "create database glpidb character set utf8 collate utf8_bin;"
mysql -u root -p$rpass -e "grant all privileges on glpidb.* to glpi@localhost identified by '$gpass';"
cd /tmp/
wget -c https://github.com/glpi-project/glpi/releases/download/9.4.6/glpi-9.4.6.tgz
tar -xvf glpi-9.4.6.tgz
mv glpi /var/www/html/
chmod 755 -R /var/www/html/glpi
chown www-data:www-data -R /var/www/html/glpi
touch /etc/nginx/sites-available/glpi
cat > /etc/nginx/sites-available/glpi <<EOF
server {
 listen 8080;
 server_name glpi.osradar.test;
 root /var/www/html/glpi;
 index index.php;
 location / {try_files \$uri \$uri/ index.php;}
 location ~ \.php$ {
 fastcgi_pass 127.0.0.1:9000;
 fastcgi_index index.php;
 include /etc/nginx/fastcgi_params;
 fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
 include fastcgi_params;
 fastcgi_param SERVER_NAME \$host;
 }
location ~ /files{
deny all;
}
 }
EOF
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/glpi /etc/nginx/sites-enabled/glpi.conf
wget https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.4%2B2.4/fusioninventory-9.4+2.4.tar.bz2
tar -xjf fusioninventory-9.4+2.4.tar.bz2 -C /var/www/html/glpi/plugins/
wget https://forge.glpi-project.org/attachments/download/2291/glpi-plugin-reports-1.13.1.tar.gz
tar -xvzf glpi-plugin-reports-1.13.1.tar.gz -C /var/www/html/glpi/plugins/
wget https://forge.glpi-project.org/attachments/download/2297/glpi-archires-2.7.0.tar.gz
tar -xvzf glpi-archires-2.7.0.tar.gz -C /var/www/html/glpi/plugins/
systemctl restart nginx php7.3-fpm