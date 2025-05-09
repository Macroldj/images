# Redis 集群部署方案详解

Redis 作为高性能的键值存储数据库，提供了多种集群部署方案。以下是几种常见的 Redis 集群部署方式及其详细的 Docker Compose 配置。

## 1. Redis 主从复制（Master-Slave Replication）

主从复制是 Redis 最基础的高可用方案，适用于读写分离和数据备份场景。

```yaml
version: '3.8'
services:
  redis-master:
    image: redis:6.2
    container_name: redis-master
    ports:
      - "6379:6379"
    volumes:
      - redis-master-data:/data
    command: redis-server --requirepass redismaster123
    networks:
      - redis-network
    restart: always

  redis-slave-1:
    image: redis:6.2
    container_name: redis-slave-1
    ports:
      - "6380:6379"
    volumes:
      - redis-slave-1-data:/data
    command: redis-server --slaveof redis-master 6379 --masterauth redismaster123 --requirepass redisslave123
    networks:
      - redis-network
    depends_on:
      - redis-master
    restart: always

  redis-slave-2:
    image: redis:6.2
    container_name: redis-slave-2
    ports:
      - "6381:6379"
    volumes:
      - redis-slave-2-data:/data
    command: redis-server --slaveof redis-master 6379 --masterauth redismaster123 --requirepass redisslave123
    networks:
      - redis-network
    depends_on:
      - redis-master
    restart: always

networks:
  redis-network:
    driver: bridge

volumes:
  redis-master-data:
  redis-slave-1-data:
  redis-slave-2-data:
```

**主从复制特点：**
- 一个主节点（Master）可以有多个从节点（Slave）
- 主节点负责写操作，从节点负责读操作
- 主节点数据自动同步到从节点
- 主节点故障时，需要手动将从节点提升为主节点

## 2. Redis Sentinel 高可用集群

Redis Sentinel 提供了自动故障转移、监控和通知功能，是生产环境中常用的高可用方案。

```yaml
version: '3.8'
services:
  redis-master:
    image: redis:6.2
    container_name: redis-master
    ports:
      - "6379:6379"
    volumes:
      - redis-master-data:/data
    command: redis-server --requirepass redis123
    networks:
      - redis-network
    restart: always

  redis-slave-1:
    image: redis:6.2
    container_name: redis-slave-1
    ports:
      - "6380:6379"
    volumes:
      - redis-slave-1-data:/data
    command: redis-server --slaveof redis-master 6379 --masterauth redis123 --requirepass redis123
    networks:
      - redis-network
    depends_on:
      - redis-master
    restart: always

  redis-slave-2:
    image: redis:6.2
    container_name: redis-slave-2
    ports:
      - "6381:6379"
    volumes:
      - redis-slave-2-data:/data
    command: redis-server --slaveof redis-master 6379 --masterauth redis123 --requirepass redis123
    networks:
      - redis-network
    depends_on:
      - redis-master
    restart: always

  sentinel-1:
    image: redis:6.2
    container_name: redis-sentinel-1
    ports:
      - "26379:26379"
    volumes:
      - ./sentinel-1.conf:/etc/redis/sentinel.conf
    command: redis-sentinel /etc/redis/sentinel.conf
    networks:
      - redis-network
    depends_on:
      - redis-master
      - redis-slave-1
      - redis-slave-2
    restart: always

  sentinel-2:
    image: redis:6.2
    container_name: redis-sentinel-2
    ports:
      - "26380:26379"
    volumes:
      - ./sentinel-2.conf:/etc/redis/sentinel.conf
    command: redis-sentinel /etc/redis/sentinel.conf
    networks:
      - redis-network
    depends_on:
      - redis-master
      - redis-slave-1
      - redis-slave-2
    restart: always

  sentinel-3:
    image: redis:6.2
    container_name: redis-sentinel-3
    ports:
      - "26381:26379"
    volumes:
      - ./sentinel-3.conf:/etc/redis/sentinel.conf
    command: redis-sentinel /etc/redis/sentinel.conf
    networks:
      - redis-network
    depends_on:
      - redis-master
      - redis-slave-1
      - redis-slave-2
    restart: always

networks:
  redis-network:
    driver: bridge

volumes:
  redis-master-data:
  redis-slave-1-data:
  redis-slave-2-data:
```

**Sentinel 配置文件示例 (sentinel-1.conf):**
```
port 26379
sentinel monitor mymaster redis-master 6379 2
sentinel auth-pass mymaster redis123
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
```

**Sentinel 特点：**
- 自动故障检测和转移
- 监控多个 Redis 主从集群
- 提供通知和配置管理
- 客户端支持 Sentinel 发现服务

## 3. Redis Cluster 分片集群

Redis Cluster 是 Redis 的分布式实现，支持数据分片、自动故障转移和线性扩展。

```yaml
version: '3.8'
services:
  redis-1:
    image: redis:6.2
    container_name: redis-1
    ports:
      - "7000:7000"
      - "17000:17000"
    volumes:
      - redis-1-data:/data
    command: redis-server --port 7000 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes --requirepass redis123 --masterauth redis123 --cluster-announce-ip 127.0.0.1
    networks:
      - redis-cluster
    restart: always

  redis-2:
    image: redis:6.2
    container_name: redis-2
    ports:
      - "7001:7001"
      - "17001:17001"
    volumes:
      - redis-2-data:/data
    command: redis-server --port 7001 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes --requirepass redis123 --masterauth redis123 --cluster-announce-ip 127.0.0.1
    networks:
      - redis-cluster
    restart: always

  redis-3:
    image: redis:6.2
    container_name: redis-3
    ports:
      - "7002:7002"
      - "17002:17002"
    volumes:
      - redis-3-data:/data
    command: redis-server --port 7002 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes --requirepass redis123 --masterauth redis123 --cluster-announce-ip 127.0.0.1
    networks:
      - redis-cluster
    restart: always

  redis-4:
    image: redis:6.2
    container_name: redis-4
    ports:
      - "7003:7003"
      - "17003:17003"
    volumes:
      - redis-4-data:/data
    command: redis-server --port 7003 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes --requirepass redis123 --masterauth redis123 --cluster-announce-ip 127.0.0.1
    networks:
      - redis-cluster
    restart: always

  redis-5:
    image: redis:6.2
    container_name: redis-5
    ports:
      - "7004:7004"
      - "17004:17004"
    volumes:
      - redis-5-data:/data
    command: redis-server --port 7004 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes --requirepass redis123 --masterauth redis123 --cluster-announce-ip 127.0.0.1
    networks:
      - redis-cluster
    restart: always

  redis-6:
    image: redis:6.2
    container_name: redis-6
    ports:
      - "7005:7005"
      - "17005:17005"
    volumes:
      - redis-6-data:/data
    command: redis-server --port 7005 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes --requirepass redis123 --masterauth redis123 --cluster-announce-ip 127.0.0.1
    networks:
      - redis-cluster
    restart: always

  redis-cluster-creator:
    image: redis:6.2
    container_name: redis-cluster-creator
    networks:
      - redis-cluster
    depends_on:
      - redis-1
      - redis-2
      - redis-3
      - redis-4
      - redis-5
      - redis-6
    command: >
      bash -c "sleep 10 && echo yes | redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 -a redis123 --cluster-replicas 1"

networks:
  redis-cluster:
    driver: bridge

volumes:
  redis-1-data:
  redis-2-data:
  redis-3-data:
  redis-4-data:
  redis-5-data:
  redis-6-data:
```

**Redis Cluster 特点：**
- 数据自动分片到多个节点
- 无中心架构
- 支持自动故障转移
- 线性扩展能力
- 默认每个主节点有一个从节点

## 4. Redis + Twemproxy 代理集群

Twemproxy（nutcracker）是 Twitter 开源的 Redis 和 Memcached 代理，支持自动分片和负载均衡。

```yaml
version: '3.8'
services:
  redis-1:
    image: redis:6.2
    container_name: redis-1
    ports:
      - "6379:6379"
    volumes:
      - redis-1-data:/data
    command: redis-server --requirepass redis123
    networks:
      - redis-network
    restart: always

  redis-2:
    image: redis:6.2
    container_name: redis-2
    ports:
      - "6380:6379"
    volumes:
      - redis-2-data:/data
    command: redis-server --requirepass redis123
    networks:
      - redis-network
    restart: always

  redis-3:
    image: redis:6.2
    container_name: redis-3
    ports:
      - "6381:6379"
    volumes:
      - redis-3-data:/data
    command: redis-server --requirepass redis123
    networks:
      - redis-network
    restart: always

  twemproxy:
    image: ganomede/twemproxy
    container_name: twemproxy
    ports:
      - "22121:22121"
      - "22122:22122"
    volumes:
      - ./nutcracker.yml:/etc/nutcracker/nutcracker.yml
    networks:
      - redis-network
    depends_on:
      - redis-1
      - redis-2
      - redis-3
    restart: always

networks:
  redis-network:
    driver: bridge

volumes:
  redis-1-data:
  redis-2-data:
  redis-3-data:
```

**Twemproxy 配置文件示例 (nutcracker.yml):**
```yaml
redis:
  listen: 0.0.0.0:22121
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: true
  redis: true
  redis_auth: redis123
  server_retry_timeout: 30000
  server_failure_limit: 3
  servers:
    - redis-1:6379:1
    - redis-2:6379:1
    - redis-3:6379:1
```

**Twemproxy 特点：**
- 轻量级代理
- 自动分片
- 减少与 Redis 的连接数
- 支持多种哈希算法

## 各方案对比

| 集群类型 | 优点 | 缺点 | 适用场景 |
|---------|------|------|----------|
| 主从复制 | 配置简单，易于维护 | 主库单点故障，需手动切换 | 读写分离、数据备份 |
| Sentinel | 自动故障转移，高可用 | 不支持分片，容量受单机限制 | 高可用性要求场景 |
| Redis Cluster | 分布式存储，线性扩展 | 配置复杂，客户端要求高 | 大规模数据存储 |
| Twemproxy | 轻量级，对客户端透明 | 单点故障，不支持动态扩容 | 简单分片需求 |

## 注意事项

1. 生产环境中，建议将各节点部署在不同的物理机上
2. 密码和敏感信息应使用环境变量或 Docker secrets 管理
3. 数据卷应妥善备份
4. 网络配置应考虑安全性，避免直接暴露 Redis 端口
5. 集群初始化脚本应自动化，避免人工操作错误
6. 对于 Redis Cluster，需要注意 `cluster-announce-ip` 的配置，确保节点间通信正常

以上配置仅供参考，实际部署时应根据业务需求和硬件资源进行调整。

        当前模型请求量过大，请求排队约 2 位，请稍候或切换至其他模型问答体验更流畅。