#!/bin/bash
dpkg-reconfigure tzdata
apt update && apt upgrade -y
apt install -y curl wget vim git unzip socat bash-completion apt-transport-https
apt install -y php7.3 php7.3-cli php7.3-fpm php7.3-gd php7.3-xml php7.3-zip
apt install -y nginx
sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php/7.3/fpm/pool.d/www.conf
touch /etc/nginx/sites-available/dokuwiki.conf
cat > /etc/nginx/sites-available/dokuwiki.conf <<EOF
server {

    listen [::]:80;
    listen 80;

    server_name 192.168.126.129;
    root /var/www/dokuwiki;
    index index.html index.htm index.php doku.php;
    
    client_max_body_size 15M;
    client_body_buffer_size 128K;
    
    location / {
        try_files $uri $uri/ @dokuwiki;
    }
    
    location ^~ /conf/ { return 403; }
    location ^~ /data/ { return 403; }
    location ~ /\.ht { deny all; }
    
    location @dokuwiki {
        rewrite ^/_media/(.*) /lib/exe/fetch.php?media=$1 last;
        rewrite ^/_detail/(.*) /lib/exe/detail.php?media=$1 last;
        rewrite ^/_export/([^/]+)/(.*) /doku.php?do=export_$1&id=$2 last;
        rewrite ^/(.*) /doku.php?id=$1 last;
    }
 location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/dokuwiki.conf /etc/nginx/sites-enabled/
systemctl reload nginx.service
mkdir -p /var/www/dokuwiki
cd /var/www/dokuwiki
wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz
tar xvzf dokuwiki-stable.tgz
rm dokuwiki-stable.tgz
cp -r dokuwiki-2018-04-22c/* /var/www/dokuwiki/
rm -rf dokuwiki-2018-04-22c
chown -R www-data:www-data /var/www/dokuwiki
systemctl restart php7.3-fpm.service nginx