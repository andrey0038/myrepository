#!/bin/bash
read -p "Введите Realm: " realmd
read -p "Введите Domain name: " dname
#read -p "Введите DNS сервер: " dns
read -p "Введите пароль для пользователя admin в домене: " passda
apt install mc samba krb5-config winbind smbclient -y
mv /etc/samba/smb.conf /etc/samba/smb.conf.org
samba-tool domain provision --use-rfc2307 --realm="$realmd" --domain="$dname" --server-role="dc" --adminpass="$passda" 
cp /var/lib/samba/private/krb5.conf /etc/
systemctl stop smbd nmbd winbind
systemctl disable smbd nmbd winbind
systemctl unmask samba-ad-dc
systemctl start samba-ad-dc
systemctl enable samba-ad-dc
samba-tool domain level show