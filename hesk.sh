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
read -p "Введите пароль для пользователя hesk в mysql: " hpass
mysql -e "SET PASSWORD FOR root@localhost = PASSWORD('$rpass');FLUSH PRIVILEGES;" 
printf "$rpass\n n\n n\n n\n y\n y\n y\n" |  mysql_secure_installation
sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php/7.3/fpm/pool.d/www.conf
mysql -u root -p$rpass -e "create database hesk character set utf8 collate utf8_bin;"
mysql -u root -p$rpass -e "grant all privileges on hesk.* to hesk@localhost identified by '$hpass';"
cd /tmp/
git clone https://github.com/andrey0038/HESK.git
cd HESK
mkdir /var/www/html/hesk
unzip hesk311.zip -d /var/www/html/hesk
unzip ru.zip -d /var/www/html/hesk/language
chmod 777 -R /var/www/html/hesk
chown www-data:www-data -R /var/www/html/hesk
touch /etc/nginx/sites-available/hesk
cat > /etc/nginx/sites-available/hesk <<EOF
server {
 listen 80;
 server_name hesk;
 root /var/www/html/hesk;
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
ln -s /etc/nginx/sites-available/hesk /etc/nginx/sites-enabled/hesk.conf
systemctl restart nginx php7.3-fpm