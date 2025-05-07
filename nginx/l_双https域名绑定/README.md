## Nginx 配置双https域名绑定
1. 检查nginx是不是支持双域名绑定？
```shell
/usr/local/nginx/sbin/nginx -V
TLS SNI support enabled
```
如果不支持，请安装插件。

2. 安装nginx https 双域名绑定插件？
```shell
./configure --prefix=/usr/local/nginx --with-http_ssl_module \
--with-openssl=./openssl-1.0.1e \
--with-openssl-opt="enable-tlsext" 
```

3. 进行双域名绑定配置.
```nginx configuration
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  2048;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;

    keepalive_timeout  65;

    server {
        listen       443 ssl;
        server_name    code-cd.jjmatch.cn;
        ssl_certificate     /etc/nginx/cert/jjmatch.cn.cer;
        ssl_certificate_key  /etc/nginx/cert/jjmatch.cn.key;
        ssl_protocols        TLSv1 TLSv1.1 TLSv1.2;
        location /static {
            alias /home/static;
        }

        location / {
            include uwsgi_params;
            uwsgi_connect_timeout 30;
            uwsgi_pass unix:/etc/nginx/socket/uwsgi.sock;
        }
    }

    server {
        listen       443 ssl;
        server_name    code.cd.tkoffice.cn;
        ssl_certificate     /etc/nginx/cert/cd.tkoffice.cn.cer;
        ssl_certificate_key  /etc/nginx/cert/cd.tkoffice.cn.key;
        ssl_protocols        TLSv1 TLSv1.1 TLSv1.2;
        location /static {
            alias /home/static;
        }

        location / {
            include uwsgi_params;
            uwsgi_connect_timeout 30;
            uwsgi_pass unix:/etc/nginx/socket/uwsgi.sock;
        }
    }

    server {
        listen       80;
        client_max_body_size 500M;
        location /static {
            alias /home/static;
        }

        location / {
            include uwsgi_params;
            uwsgi_connect_timeout 30;
            uwsgi_pass unix:/etc/nginx/socket/uwsgi.sock;
        }
    }
}
```
4. nginx 进行重启
```shell
nginx -S reload
```
