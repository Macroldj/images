# nginx 网关服务

网关(Gateway) 是转发其它服务器通信数据的服务器，接收客户端发送来的请求时，它就像自己拥有资源的源服务器一样对请求进行 处理。
有时候客户端可能都不会察觉，自己的通信目标是一个网关。

优点：

1. 可以对服务提供统一管理，例如给服务统一设置 HTTPS 、 压缩等功能
2. 对于拥有公网 IP 不足，但具有多台服务器的场景，可以提供一种解决公网 IP 不足的方案
3. 域名统一使用的方案。

缺点:

1. 因为网关服务作为所有服务入口，那么网关承载了所有访问压力。
2. 对网关服务依赖性较强，当网关一挂掉，那所有服务对于外网都处于都不可见状态。

## 使用场景

1. 聚合服务

```nginx configuration
http {
    include mime.types;
    default_type text/html;
    sendfile on;
    keepalive_timeout 65;
    charset utf-8;
    server {
        listen 80;
        error_log  /var/log/nginx/portainer/error.log;
        access_log  /var/log/nginx/portainer/access.log;
        location / {
            proxy_pass http://10.0.24.12:9000;
        }
        location / {
            proxy_pass http://10.0.24.12:9000;
        }
        location /a {
            proxy_pass http://10.0.24.12:9000;
        }
        location /b {
            proxy_pass http://10.0.24.12:9000;
        }
        location /c {
            proxy_pass http://10.0.24.12:9000;
        }
        location /d {
            proxy_pass http://10.0.24.12:9000;
        }
        location /e {
            proxy_pass http://10.0.24.12:9000;
        }
    }
    }
```

2. 对外请求进行文件压缩

```nginx configuration
http {
    include mime.types;
    default_type text/html;
    sendfile on;
    keepalive_timeout 65;
    charset utf-8;

    # 开启压缩
    # 压缩版本
    # 文件压缩类型
    gzip_types text/plain text/css application/javascript application/json application/xml;
    #设置压缩比率
    gzip_comp_level 5;
}
```

3. https 服务公用证书

```nginx configuration
server {
    #SSL 访问端口号为 443
    listen 443 ssl http2;
    #填写绑定证书的域名
    server_name portainer.mwjz.live;
    #日志
    error_log  /var/log/nginx/portainer/error.log;
    access_log  /var/log/nginx/portainer/access.log;
    #证书文件
    ssl_certificate /etc/nginx/conf.d/ssl/portainer/portainer.mwjz.live_bundle.crt;
    #证书密钥文件
    ssl_certificate_key /etc/nginx/conf.d/ssl/portainer/portainer.mwjz.live.key;

    ssl_ciphers SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!3DES:!aNULL:!MD5:!ADH:!RC4;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    location / {
        proxy_pass http://10.0.24.12:9000;
    }
}
```