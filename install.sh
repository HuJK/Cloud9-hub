#!/bin/bash
apt-get update
apt-get update  -y
apt-get install -y nginx-full
apt-get install -y libnginx-mod-http-auth-pam
apt-get install -y lua5.2 lua5.2-doc liblua5.2-dev
apt-get install -y luajit
apt-get install -y libnginx-mod-http-lua
apt-get install -y tmux gdbserver gdb git python python-pip python3 python3-pip build-essential wget libncurses-dev nodejs npm golang coffeescript  default-jdk coffeescript php-cli php-fpm ruby
curl https://install.meteor.com/ | sh
pip3 install pexpect
sudo npm install socket.io

mkdir /etc/c9
mkdir /etc/c9/sock
mkdir /etc/c9/util
wget -O- https://raw.githubusercontent.com/kikito/md5.lua/master/md5.lua > /etc/c9/util/md5.lua
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/pip2su.py > /etc/c9/util/pip2su.py

cd /etc/c9
HOME=/etc/c9
git clone https://github.com/c9/core sdk
cd sdk
./scripts/install-sdk.sh

chmod -R 755 /etc/c9/sdk
chmod -R 755 /etc/c9/.c9
chmod -R 755 /etc/c9/util
chmod -R 773 /etc/c9/sock
HOME=/root

usermod -aG shadow nginx
usermod -aG shadow www-data
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/c9io > /etc/nginx/sites-available/c9io
ln -s ../sites-available/c9io /etc/nginx/sites-enabled/c9io
cd /etc/c9
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/logout.patch | patch -p0

apt-get install -y install openssl
mkdir /etc/c9/cert
chmod 600 /etc/c9/cert
cd /etc/c9/cert
openssl genrsa -out ssl.key 2048
openssl req -new -x509 -key ssl.key -out ssl.pem -days 3650 -subj /CN=localhost
