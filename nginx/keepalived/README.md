# Keepalived双主机互备测试方案

本项目实现了基于Keepalived的双主机互备高可用方案，两台Nginx服务器互为备份，同时提供服务，实现高可用性。

## 方案架构

- 两台Nginx服务器，分别配置Keepalived
- 每台服务器同时作为一个VIP的主服务器和另一个VIP的备份服务器
- 当一台服务器故障时，另一台服务器将接管所有流量

## 配置说明

### 虚拟IP (VIP)

- VIP1: 192.168.1.200 - 默认由nginx-master管理
- VIP2: 192.168.1.201 - 默认由nginx-backup管理

### 服务器角色

- nginx-master: 
  - 对VIP1为MASTER (优先级100)
  - 对VIP2为BACKUP (优先级90)
  
- nginx-backup:
  - 对VIP1为BACKUP (优先级90)
  - 对VIP2为MASTER (优先级100)

## 测试方法

1. 启动服务：

```bash
docker-compose up -d