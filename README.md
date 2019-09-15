# Cloud9 Hub
Simple hub page for Cloud9 SDK. Each user has one workspace, authenticate with linux pam module.

This is an nginx reverse proxy config which will try to authenticate user:password with linux pam module ,and try to execute command to spawn a cloud9 workspace by that user, and then proxy_pass to it.

Prenstall (according on my memory, not test on clean environment yet)
--

debian/ubuntu (run as root):
```bash
apt-get install -y nginx-full
apt-get install -y libnginx-mod-http-auth-pam
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
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/c9io > /etc/nginx/sites-available/c9io
ln -s ../sites-available/c9io /etc/nginx/sites-enabled/c9io
cd /etc/c9
wget -O- https://raw.githubusercontent.com/HuJK/Cloud9Hub/master/logout.patch | patch -p0
```

Postinstall.
--
Edit ```/etc/nginx/sites-enabled/c9io``` with vim, nano, or any other text editior with root. And follow following instructions.

###### 1. Change port number
Edit line 8~9
```
    listen 8443 ssl;
    listen [::]:8443 ssl;
``` 
from 8443 to other ports that you prefer.

###### 2. Spacify ssl certificates
2. Edit line 10~11
```
    ssl_certificate     /etc/nginx_ssl/lab.pem;
    ssl_certificate_key /etc/nginx_ssl/lab.key;
```
to your certificate and keys.

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
