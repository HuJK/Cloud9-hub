# Cloud9Hub
Simple hub page for Cloud9 SDK. Each user has one workspace, auth with linux pam module.

A nginx reverse proxy config which will try to authentic user with linux pam module ,and try to execute command to spawn a cloud9 workspace by that user, and proxy_pass to it.

Edit domain
--
First, edit 
```
c9.example.com
```
to your domain name o

Prenstall (according on my memory, not test on clean environment yet)
--

debian/ubuntu (run as root):
```bash
apt-get install -y nginx-full
apt-get install -y lua5.2 lua5.2-doc liblua5.2-dev
apt-get install -y luajit
apt-get install -y libnginx-mod-http-lua
apt-get install -y tmux gdbserver git

mkdir /etc/c9
mkdir /etc/c9/sock
mkdir /etc/c9/util
chmod 777 /etc/c9/sock
wget -O- https://raw.githubusercontent.com/kikito/md5.lua/master/md5.lua > /etc/c9/util/md5.lua

cd /etc/c9
git clone https://github.com/c9/core sdk
cd sdk
./scripts/install-sdk.sh

chmod -R 755 /etc/c9/sdk

cp -r ~/.c9 /etc/c9
chmod -R 755 /etc/c9/sdk
chmod -R 755 /etc/c9/.c9
```

Install
--

```bash
usermod -aG shadow nginx
usermod -aG shadow www-data
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/c9io.conf > /etc/nginx/sites-enabled/c9io
```

Config
--

edit ```/etc/nginx/sites-enabled/c9io``` with vim nano or other text editior
```
 8    server_name c9.example.com;
17    server_name c9.example.com;
```
modyfy ```c9.example.com``` to your domain.

if you don't have a domain, modify ```c9.example.com``` to ```default_server```. 
And edit ``` listen 80;  listen 443 ssl;``` to other ports.
