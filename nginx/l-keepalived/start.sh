#!/bin/bash

# 确定使用哪个配置文件
if [ "$KEEPALIVED_ROLE" = "master" ]; then
    cp /etc/keepalived/keepalived-master.conf /etc/keepalived/keepalived.conf
else
    cp /etc/keepalived/keepalived-backup.conf /etc/keepalived/keepalived.conf
fi

# 替换配置文件中的网络接口名称
if [ ! -z "$INTERFACE" ]; then
    sed -i "s/interface eth0/interface $INTERFACE/g" /etc/keepalived/keepalived.conf
fi

# 替换配置文件中的虚拟IP地址
if [ ! -z "$VIRTUAL_IP1" ]; then
    sed -i "s/192.168.1.200/$VIRTUAL_IP1/g" /etc/keepalived/keepalived.conf
fi

if [ ! -z "$VIRTUAL_IP2" ]; then
    sed -i "s/192.168.1.201/$VIRTUAL_IP2/g" /etc/keepalived/keepalived.conf
fi

# 启动Nginx
nginx

# 启动Keepalived
keepalived -n -l -D -f /etc/keepalived/keepalived.conf