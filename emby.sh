#!/bin/bash
apt install samba samba-client cifs-utils -y
mkdir /home/samba
chmod 777 /home/samba/
mkdir /home/samba/media
chmod 777 /home/samba/media/
mkdir /home/samba/progs
chmod 777 /home/samba/progs/
useradd emby
smbpasswd -a emby
cat > /etc/samba/smb.conf <<EOF 
[media]
path = /home/samba/media
browseable = yes
writable = yes
write list = emby
valid users = emby
guest ok = no
#hosts allow = 192.168.0.171
EOF
service smbd reload
wget -nv http://download.opensuse.org/repositories/home:emby/Debian_9.0/Release.key -O Release.key
apt-key add - < Release.key
apt-get update
echo 'deb http://download.opensuse.org/repositories/home:/emby/Debian_9.0/ /' > /etc/apt/sources.list.d/emby-server.list 
apt-get update
apt-get install emby-server -y
service emby-server start