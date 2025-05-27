# 使用基础镜像
FROM registry.cn-hangzhou.aliyuncs.com/macroldj/ubuntu:22.04-base

# 避免在安装过程中出现交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新软件包列表并安装 cron
RUN apt-get update && apt-get install -y cron mysql postgresql-client
# 清理软件包列表
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 创建日志文件目录
RUN mkdir -p /var/log/cron

# 创建一个简单的脚本，用于记录当前时间
RUN echo '#!/bin/bash' > /usr/local/bin/log_time.sh
RUN echo 'date >> /var/log/cron/time.log 2>&1' >> /usr/local/bin/log_time.sh
RUN chmod +x /usr/local/bin/log_time.sh

# 添加 cron 任务到 crontab
RUN echo '* * * * * root /usr/local/bin/log_time.sh' > /etc/cron.d/time-log-cron

# 给 cron 任务文件添加适当的权限
RUN chmod 0644 /etc/cron.d/time-log-cron

# 启动 cron 服务
CMD ["cron", "-f"]