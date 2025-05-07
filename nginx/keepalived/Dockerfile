FROM nginx:1.21-alpine

# 安装keepalived和必要的工具
RUN apk add --no-cache keepalived bash procps

# 复制配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY check_nginx.sh /usr/bin/check_nginx.sh
RUN chmod +x /usr/bin/check_nginx.sh

# 创建启动脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 暴露端口
EXPOSE 80 443

# 启动服务
CMD ["/start.sh"]