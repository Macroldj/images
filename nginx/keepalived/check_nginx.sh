#!/bin/bash

# 检查Nginx进程是否存在
if [ $(ps -C nginx --no-header | wc -l) -eq 0 ]; then
    # 尝试启动Nginx
    systemctl start nginx
    # 等待2秒
    sleep 2
    # 再次检查Nginx是否启动
    if [ $(ps -C nginx --no-header | wc -l) -eq 0 ]; then
        # 如果Nginx仍未启动，则退出并返回状态码1
        exit 1
    fi
fi

# Nginx正在运行，返回状态码0
exit 0