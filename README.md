# Cloud9Hub
Simple hub page for Cloud9 SDK. Each user has one workspace, auth with linux pam module.

A nginx reverse proxy config which will try to authentic user with linux pam module ,and try to execute command to spawn a cloud9 workspace by that user, and proxy_pass to it.

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

Postinstall.
--
Edit ```/etc/nginx/sites-enabled/c9io``` with vim, nano, or any other text editior with root. And follow following instructions.

#### domain based virtual host:
Edit this part:
```
 8    server_name c9.example.com;
17    server_name c9.example.com;
```
modify ```c9.example.com``` to your domain.

#### port based virtual host:
1. Same as previous step, but modify ```c9.example.com``` to ```default_server```. 

2. And edit ```listen 443 ssl;``` from 443 to other ports that you prefer.

3. **Remove** this part from config:
```
server {
    listen 80;
    server_name c9.example.com;
    #password transfer by http_basic_auth. It's very dangerous to transfer it without encryption.
    return 302 https://$host$request_uri;
}
```

#### Config https certificate
1. Edit this part
```
    ssl_certificate     /etc/nginx_ssl/lab.pem;
    ssl_certificate_key /etc/nginx_ssl/lab.key;
```
to your certificate and keys.

#### Switch to http.(if you don't have a valid ssl certificate)

I strongly recommend that you should use https instead of http for this site or any other site for security reason. 

You can get it latsencrypte for free.

That's why I disable http access by default. 

But if you just want to test, or not host in public network, You can do following steps.

1. **Remove** this part
```
    ssl_certificate     /etc/nginx_ssl/lab.pem;
    ssl_certificate_key /etc/nginx_ssl/lab.key;
```

2. Modify from (assume you use 8080 pprt)
```
listen 8080 ssl;
listen [::]:8080 ssl;
```
to
```
listen 8080;
listen [::]:8080;
```

Now, reload nginx with ```nginx -s reload```
