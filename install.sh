#!/bin/bash
set -e
echo "###update phase###"
apt-get update
apt-get upgrade -y
set +e
# In my distro(debian 10), It seems nginx and nginx-full are not compatible. I have to remove nginx than I can install nginx-full.
apt-get remove -y nginx
# The install script will detect npm exist or not on the system. If exist, it will not use itself's npm
# But in Ubuntu 19.04, npm from apt are not compatible with it. So I have to remove first, and install back later.
apt-get remove -y npm
apt-get autoremove -y
set -e
echo "###install dependanse phase###"
apt-get install -y nginx-full
apt-get install -y libnginx-mod-http-auth-pam
apt-get install -y lua5.2 lua5.2-doc liblua5.2-dev
apt-get install -y luajit
apt-get install -y libnginx-mod-http-lua
apt-get install -y tmux gdbserver gdb git python python3 build-essential wget libncurses-dev nodejs 
apt-get install -y python-pip python3-pip golang default-jdk coffeescript php-cli php-fpm ruby
apt-get install -y zsh fish tree ncdu aria2 p7zip-full python3-dev perl curl
set +e # folling command only have one will success
#cockpit for user management
apt-get install -y -t bionic-backports cockpit cockpit-pcp #for ubuntu 18.04
apt-get install -y cockpit cockpit-pcp                     #for ubuntu 19.04
set -e
curl https://install.meteor.com/ | sh
pip3 install pexpect
pip3 install IKP3db
pip install ikpdb

echo "###create folder structure###"
rm -rf /etc/c9 || true
mkdir /etc/c9
mkdir /etc/c9/sock
mkdir /etc/c9/util

echo "###download utils###"
wget https://raw.githubusercontent.com/kikito/md5.lua/master/md5.lua -O /etc/c9/util/md5.lua
wget https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/pip2su.py -O /etc/c9/util/pip2su.py
wget https://raw.githubusercontent.com/HuJK/Cloud9-hub/master/create_login.py -O /etc/c9/util/create_login.py

echo "###install c9 sdk by offical installitaion script###"
cd /etc/c9
HOME=/etc/c9
git clone https://github.com/c9/core sdk
cd sdk
./scripts/install-sdk.sh

echo "###set permission###"
chmod -R 755 /etc/c9/sdk
chmod -R 755 /etc/c9/.c9
chmod -R 755 /etc/c9/util
chmod -R 773 /etc/c9/sock
HOME=/root

# Install npm back
apt-get install -y npm
set +e 
echo "###add nginx to shadow to make pam_module work###"
usermod -aG shadow nginx
usermod -aG shadow www-data
set -e 
echo "###install Cloud9-hub to nginx config###"
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/c9io > /etc/nginx/sites-available/c9io
ln -sfn ../sites-available/c9io /etc/nginx/sites-enabled/c9io
cd /etc/c9

echo "###patch for login logout account and dashboard###"
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/logout.patch | patch -p0
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/standalone.patch | patch -p0
echo "###patch for python3###"
mkdir -p /etc/c9/.c9/runners/
wget https://raw.githubusercontent.com/HuJK/Cloud9-hub/master/Python%203.run -O "/etc/c9/.c9/runners/Python 3.run"
set +e
echo "###generate self signed cert###"
echo "###You should buy or get a valid ssl certs           ###"
echo "###Now I generate a self singed certs in /etc/c9/cert###"
echo "###But you should replace it with valid a ssl certs  ###"
echo '###Remember update your cert for cockpit too!        ###'
echo '### cat ssl.pem ssl.key > /etc/cockpit/ws-certs.d/0-self-signed.cert###'
apt-get install -y install openssl
mkdir /etc/c9/cert
chmod 600 /etc/c9/cert
cd /etc/c9/cert
openssl genrsa -out ssl.key 2048
openssl req -new -x509 -key ssl.key -out ssl.pem -days 3650 -subj /CN=localhost
cat ssl.pem ssl.key > /etc/cockpit/ws-certs.d/0-self-signed.cert

echo "###restart nginx and cockpit###"
systemctl enable nginx
systemctl enable cockpit.socket
service nginx stop
service nginx start
service cockpit stop
service cockpit start
