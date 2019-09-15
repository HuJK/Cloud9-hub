# Cloud9 Hub
Simple hub page for Cloud9 SDK. Each user has one workspace, authenticate with linux pam module.

This is an nginx reverse proxy config which will try to authenticate user:password with linux pam module ,and try to execute command to spawn a cloud9 workspace by that user, and then proxy_pass to it.

Prenstall (according on my memory, not test on clean environment yet)
--

debian/ubuntu (run as root):
```bash
apt-get update
apt-get install -y nginx-full
apt-get install -y libnginx-mod-http-auth-pam
apt-get install -y lua5.2 lua5.2-doc liblua5.2-dev
apt-get install -y luajit
apt-get install -y libnginx-mod-http-lua
apt-get install -y tmux gdbserver git python python-pip python3 python3-pip build-essential wget libncurses-dev nodejs npm golang
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
chmod -R 777 /etc/c9/sock
HOME=/root
```

Install
--

```bash
usermod -aG shadow nginx
usermod -aG shadow www-data
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/c9io > /etc/nginx/sites-available/c9io
ln -s ../sites-available/c9io /etc/nginx/sites-enabled/c9io
cd /etc/c9
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/logout.patch | patch -p0
```

Postinstall.
--
Edit ```/etc/nginx/sites-enabled/c9io``` with vim, nano, or any other text editior with root. And follow following instructions.

###### 1. Configure ssl certificates
1. Buy or get a free domain
2. Get a valid certificate from letsencrypt
3. Edit line 10~11
```
    ssl_certificate     /etc/c9/cert/ssl.pem;
    ssl_certificate_key /etc/c9/cert/ssl.key;
```
to your certificate and keys.

Alternative: use self-signed certificates:
```bash
apt-get install -y install openssl
mkdir /etc/c9/cert
chmod 600 /etc/c9/cert
cd /etc/c9/cert
openssl genrsa -out ssl.key 2048
openssl req -new -x509 -key ssl.key -out ssl.pem -days 3650 -subj /CN=localhost
```


###### 2. Change port number(if you want)
Edit line 8~9
```
    listen 8443 ssl;
    listen [::]:8443 ssl;
``` 
from 8443 to other ports that you prefer.

###### Enable http.(if you don't have a valid ssl certificate)

I strongly recommend that you should use https instead of http for security reason. 

You can get it from letsencrypt for free.

But if you just want to test, or not host in public network, You can do following steps.

1. **Remove** this part
```
    ssl_certificate     /etc/nginx_ssl/lab.pem;
    ssl_certificate_key /etc/nginx_ssl/lab.key;
```

2.  **Remove** keyword ```ssl``` at line 8~9 
from (assume you use 8080 pprt)
```
    listen 8443 ssl;
    listen [::]:8443 ssl;
```
to
```
    listen 8443;
    listen [::]:8443;
```


Now, reload nginx with ```nginx -s reload```
