nginx 静态网站代理主要配置
---
```shell
    listen       80;
    server_name  localhost; # 一般是指域名地址
    location / { # 默认的访问地址
        root   /var/www; # 文件地址
        index  index.html index.htm; # index 文件索引地址
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
    ssi on;
```