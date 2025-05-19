# n8n 高可用部署方案

n8n 是一个强大的工作流自动化平台，本方案提供了一个完整的高可用部署配置，适用于生产环境。

## 架构概述

本高可用部署方案包含以下组件：

1. **多主节点设置**：多个 n8n 主实例，确保高可用性
2. **工作节点池**：多个工作节点处理工作流执行
3. **Webhook 处理器**：专门处理 webhook 请求的节点
4. **PostgreSQL 数据库**：存储工作流和执行数据
5. **Redis**：作为消息代理，协调各节点之间的通信
6. **Nginx**：负载均衡器，分发请求到适当的节点
7. **监控系统**：Prometheus 和 Grafana 用于监控和可视化

## 目录结构

```
flow/n8n/ha/
├── docker-compose.yaml       # 主配置文件
├── .env.example              # 环境变量示例文件
├── generate-ssl-cert.sh      # 生成SSL证书的脚本
├── nginx/                    # Nginx配置
│   └── conf.d/               # Nginx配置文件
│       └── n8n.conf          # n8n的Nginx配置
├── postgres/                 # PostgreSQL配置
│   └── init/                 # PostgreSQL初始化脚本
│       └── 01-init.sql       # 数据库初始化SQL
├── prometheus/               # Prometheus配置
│   └── prometheus.yml        # Prometheus配置文件
├── grafana/                  # Grafana配置
│   └── provisioning/         # Grafana预配置
│       ├── datasources/      # 数据源配置
│       │   └── prometheus.yml # Prometheus数据源
│       └── dashboards/       # 仪表板配置
│           └── n8n.yml       # n8n仪表板配置
└── README.md                 # 说明文档
```

## 部署步骤

### 1. 准备环境

1. 确保已安装 Docker 和 Docker Compose
2. 克隆此仓库到您的服务器

### 2. 配置环境变量

1. 复制环境变量示例文件并进行配置：

```bash
cp .env.example .env
```

2. 编辑 `.env` 文件，设置所有必要的环境变量：
   - 数据库凭据
   - Redis 密码
   - n8n 加密密钥
   - SMTP 设置
   - 域名设置

### 3. 生成 SSL 证书

对于开发环境，可以使用自签名证书：

```bash
chmod +x generate-ssl-cert.sh
./generate-ssl-cert.sh
```

对于生产环境，建议使用 Let's Encrypt 获取有效的 SSL 证书。

### 4. 修改配置文件

1. 编辑 `nginx/conf.d/n8n.conf` 文件，将 `n8n.example.com` 替换为您的实际域名。
2. 根据需要调整 `docker-compose.yaml` 中的资源限制和副本数量。

### 5. 启动服务

```bash
docker-compose up -d
```

### 6. 验证部署

1. 访问 `https://your-domain.com` 确认 n8n 界面正常加载
2. 访问 `https://your-domain.com:3000` 查看 Grafana 监控面板
3. 检查所有容器状态：

```bash
docker-compose ps
```

## 高可用特性

1. **多主节点架构**：多个 n8n 主节点确保即使一个节点故障，服务仍然可用
2. **工作节点扩展**：可以根据负载动态增加或减少工作节点数量
3. **Webhook 处理器分离**：专门的 Webhook 处理器确保高并发 Webhook 请求的处理
4. **数据持久化**：所有数据存储在 PostgreSQL 和持久卷中
5. **负载均衡**：Nginx 负载均衡器确保请求均匀分布
6. **会话粘性**：使用 IP 哈希确保用户会话保持在同一主节点
7. **健康检查**：所有服务都配置了健康检查，确保只有健康的实例接收流量
8. **资源限制**：每个服务都有资源限制，防止单个服务消耗过多资源
9. **监控和告警**：Prometheus 和 Grafana 提供全面的监控和告警功能

## 扩展建议

1. **备份策略**：设置定期备份 PostgreSQL 数据库和 n8n 数据
2. **地理分布**：考虑在不同地理位置部署多个实例，实现地理冗余
3. **自动扩展**：根据负载自动扩展工作节点数量
4. **CDN 集成**：使用 CDN 加速静态资源加载
5. **日志管理**：集成 ELK 或 Graylog 进行集中日志管理
6. **安全增强**：添加 WAF 和 DDoS 防护
7. **多云部署**：考虑跨多个云提供商部署，避免单点故障

## 故障排除

### 常见问题

1. **数据库连接问题**：
   - 检查 PostgreSQL 容器是否运行
   - 验证数据库凭据是否正确
   - 确认网络连接是否正常

2. **Redis 连接问题**：
   - 检查 Redis 容器是否运行
   - 验证 Redis 密码是否正确
   - 确认网络连接是否正常

3. **Webhook 不工作**：
   - 检查 Nginx 配置是否正确
   - 确认 Webhook URL 设置是否正确
   - 验证 SSL 证书是否有效

### 查看日志

```bash
# 查看主节点日志
docker-compose logs n8n-main

# 查看工作节点日志
docker-compose logs n8n-worker

# 查看 Webhook 处理器日志
docker-compose logs n8n-webhook
```

## 维护操作

### 更新 n8n

1. 更新 Docker 镜像：

```bash
docker-compose pull
```

2. 重启服务：

```bash
docker-compose up -d
```

### 备份数据

1. 备份 PostgreSQL 数据库：

```bash
docker-compose exec postgres pg_dump -U n8n n8n > n8n_backup_$(date +%Y%m%d).sql
```

2. 备份 n8n 数据卷：

```bash
docker run --rm -v n8n-main-data:/source -v $(pwd):/backup alpine tar -czf /backup/n8n_data_$(date +%Y%m%d).tar.gz -C /source .
```

## 参考资料

- [n8n 官方文档](https://docs.n8n.io/)
- [n8n 队列模式配置](https://docs.n8n.io/hosting/scaling/queue-mode/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [Nginx 负载均衡文档](https://nginx.org/en/docs/http/load_balancing.html)
- [PostgreSQL 文档](https://www.postgresql.org/docs/)
- [Redis 文档](https://redis.io/documentation)
