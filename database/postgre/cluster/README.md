# PostgreSQL 集群部署方案详解

PostgreSQL 作为一种强大的开源关系型数据库，提供了多种集群部署方案。以下是几种常见的 PostgreSQL 集群部署方式及其详细的 Docker Compose 配置。

## 1. 主从复制（Streaming Replication）

主从复制是 PostgreSQL 最基础的高可用方案，适用于读写分离和数据备份场景。

```yaml
version: '3.8'
services:
  pg-master:
    image: postgres:14
    container_name: pg-master
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
      POSTGRES_DB: appdb
    ports:
      - "5432:5432"
    volumes:
      - pg-master-data:/var/lib/postgresql/data
      - ./pg-master/postgresql.conf:/etc/postgresql/postgresql.conf
      - ./pg-master/pg_hba.conf:/etc/postgresql/pg_hba.conf
    command: postgres -c 'config_file=/etc/postgresql/postgresql.conf'
    networks:
      - pg-network
    restart: always

  pg-slave:
    image: postgres:14
    container_name: pg-slave
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
      POSTGRES_DB: appdb
    ports:
      - "5433:5432"
    volumes:
      - pg-slave-data:/var/lib/postgresql/data
      - ./pg-slave/postgresql.conf:/etc/postgresql/postgresql.conf
      - ./pg-slave/pg_hba.conf:/etc/postgresql/pg_hba.conf
    command: postgres -c 'config_file=/etc/postgresql/postgresql.conf'
    networks:
      - pg-network
    depends_on:
      - pg-master
    restart: always

networks:
  pg-network:
    driver: bridge

volumes:
  pg-master-data:
  pg-slave-data:
```

**主库配置文件 (pg-master/postgresql.conf):**
```
listen_addresses = '*'
wal_level = replica
max_wal_senders = 10
wal_keep_size = 64
max_replication_slots = 10
hot_standby = on
```

**主库访问控制 (pg-master/pg_hba.conf):**
```
# 允许从库复制
host replication postgres 0.0.0.0/0 md5
# 允许所有数据库连接
host all all 0.0.0.0/0 md5
```

**从库配置文件 (pg-slave/postgresql.conf):**
```
listen_addresses = '*'
hot_standby = on
```

**从库访问控制 (pg-slave/pg_hba.conf):**
```
# 允许所有数据库连接
host all all 0.0.0.0/0 md5
```

**初始化步骤:**
1. 启动主库：
```bash
docker-compose up -d pg-master
```

2. 在主库创建复制槽：
```sql
SELECT pg_create_physical_replication_slot('replica_slot');
```

3. 备份主库数据到从库：
```bash
docker exec -it pg-master pg_basebackup -h pg-master -D /tmp/data -U postgres -P -v -R -X stream -C -S replica_slot
docker cp pg-master:/tmp/data/. pg-slave-data/
```

4. 启动从库：
```bash
docker-compose up -d pg-slave
```

## 2. Patroni + etcd 高可用集群

Patroni 是一个用于自动管理 PostgreSQL 高可用的工具，结合 etcd 可以实现自动故障转移。

```yaml
version: '3.8'
services:
  etcd:
    image: bitnami/etcd:3
    container_name: etcd
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd:2379
    ports:
      - "2379:2379"
    networks:
      - pg-network
    restart: always

  patroni1:
    image: registry.opensource.zalan.do/acid/patroni:2.1.1
    container_name: patroni1
    environment:
      PATRONI_SCOPE: pg-cluster
      PATRONI_NAME: patroni1
      PATRONI_ETCD_HOSTS: "'etcd:2379'"
      PATRONI_RESTAPI_USERNAME: admin
      PATRONI_RESTAPI_PASSWORD: admin
      PATRONI_ADMIN_OPTIONS: createrole,createdb
      PATRONI_POSTGRESQL_CONNECT_ADDRESS: patroni1:5432
      PATRONI_POSTGRESQL_LISTEN: 0.0.0.0:5432
      PATRONI_RESTAPI_LISTEN: 0.0.0.0:8008
      PATRONI_POSTGRESQL_DATA_DIR: /data/patroni
      PATRONI_REPLICATION_USERNAME: replicator
      PATRONI_REPLICATION_PASSWORD: replpass
      PATRONI_SUPERUSER_USERNAME: postgres
      PATRONI_SUPERUSER_PASSWORD: postgres
    volumes:
      - patroni1-data:/data
    ports:
      - "5432:5432"
      - "8008:8008"
    networks:
      - pg-network
    depends_on:
      - etcd
    restart: always

  patroni2:
    image: registry.opensource.zalan.do/acid/patroni:2.1.1
    container_name: patroni2
    environment:
      PATRONI_SCOPE: pg-cluster
      PATRONI_NAME: patroni2
      PATRONI_ETCD_HOSTS: "'etcd:2379'"
      PATRONI_RESTAPI_USERNAME: admin
      PATRONI_RESTAPI_PASSWORD: admin
      PATRONI_ADMIN_OPTIONS: createrole,createdb
      PATRONI_POSTGRESQL_CONNECT_ADDRESS: patroni2:5432
      PATRONI_POSTGRESQL_LISTEN: 0.0.0.0:5432
      PATRONI_RESTAPI_LISTEN: 0.0.0.0:8008
      PATRONI_POSTGRESQL_DATA_DIR: /data/patroni
      PATRONI_REPLICATION_USERNAME: replicator
      PATRONI_REPLICATION_PASSWORD: replpass
      PATRONI_SUPERUSER_USERNAME: postgres
      PATRONI_SUPERUSER_PASSWORD: postgres
    volumes:
      - patroni2-data:/data
    ports:
      - "5433:5432"
      - "8009:8008"
    networks:
      - pg-network
    depends_on:
      - etcd
    restart: always

  patroni3:
    image: registry.opensource.zalan.do/acid/patroni:2.1.1
    container_name: patroni3
    environment:
      PATRONI_SCOPE: pg-cluster
      PATRONI_NAME: patroni3
      PATRONI_ETCD_HOSTS: "'etcd:2379'"
      PATRONI_RESTAPI_USERNAME: admin
      PATRONI_RESTAPI_PASSWORD: admin
      PATRONI_ADMIN_OPTIONS: createrole,createdb
      PATRONI_POSTGRESQL_CONNECT_ADDRESS: patroni3:5432
      PATRONI_POSTGRESQL_LISTEN: 0.0.0.0:5432
      PATRONI_RESTAPI_LISTEN: 0.0.0.0:8008
      PATRONI_POSTGRESQL_DATA_DIR: /data/patroni
      PATRONI_REPLICATION_USERNAME: replicator
      PATRONI_REPLICATION_PASSWORD: replpass
      PATRONI_SUPERUSER_USERNAME: postgres
      PATRONI_SUPERUSER_PASSWORD: postgres
    volumes:
      - patroni3-data:/data
    ports:
      - "5434:5432"
      - "8010:8008"
    networks:
      - pg-network
    depends_on:
      - etcd
    restart: always

  haproxy:
    image: haproxy:2.4
    container_name: haproxy
    volumes:
      - ./haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
    ports:
      - "5000:5000"  # PostgreSQL 读写端口
      - "5001:5001"  # PostgreSQL 只读端口
      - "7000:7000"  # HAProxy 状态页面
    networks:
      - pg-network
    depends_on:
      - patroni1
      - patroni2
      - patroni3
    restart: always

networks:
  pg-network:
    driver: bridge

volumes:
  patroni1-data:
  patroni2-data:
  patroni3-data:
```

**HAProxy 配置文件 (haproxy/haproxy.cfg):**
```
global
    maxconn 100
    log stdout format raw local0

defaults
    log global
    mode tcp
    retries 2
    timeout client 30m
    timeout connect 4s
    timeout server 30m
    timeout check 5s

listen stats
    mode http
    bind *:7000
    stats enable
    stats uri /
    stats refresh 10s

listen postgres_write
    bind *:5000
    option httpchk
    http-check send meth GET uri /master
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server patroni1 patroni1:5432 maxconn 100 check port 8008
    server patroni2 patroni2:5432 maxconn 100 check port 8008
    server patroni3 patroni3:5432 maxconn 100 check port 8008

listen postgres_read
    bind *:5001
    option httpchk
    http-check send meth GET uri /replica
    http-check expect status 200
    default-server inter 3s fall 3 rise 2 on-marked-down shutdown-sessions
    server patroni1 patroni1:5432 maxconn 100 check port 8008
    server patroni2 patroni2:5432 maxconn 100 check port 8008
    server patroni3 patroni3:5432 maxconn 100 check port 8008
```

## 3. PostgreSQL + PgPool-II 读写分离集群

PgPool-II 是一个 PostgreSQL 中间件，提供连接池、负载均衡和自动故障转移功能。

```yaml
version: '3.8'
services:
  pg-master:
    image: postgres:14
    container_name: pg-master
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
      POSTGRES_DB: appdb
    volumes:
      - pg-master-data:/var/lib/postgresql/data
      - ./pg-master/postgresql.conf:/etc/postgresql/postgresql.conf
      - ./pg-master/pg_hba.conf:/etc/postgresql/pg_hba.conf
    command: postgres -c 'config_file=/etc/postgresql/postgresql.conf'
    networks:
      - pg-network
    restart: always

  pg-slave1:
    image: postgres:14
    container_name: pg-slave1
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
      POSTGRES_DB: appdb
    volumes:
      - pg-slave1-data:/var/lib/postgresql/data
      - ./pg-slave/postgresql.conf:/etc/postgresql/postgresql.conf
      - ./pg-slave/pg_hba.conf:/etc/postgresql/pg_hba.conf
    command: postgres -c 'config_file=/etc/postgresql/postgresql.conf'
    networks:
      - pg-network
    depends_on:
      - pg-master
    restart: always

  pg-slave2:
    image: postgres:14
    container_name: pg-slave2
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
      POSTGRES_DB: appdb
    volumes:
      - pg-slave2-data:/var/lib/postgresql/data
      - ./pg-slave/postgresql.conf:/etc/postgresql/postgresql.conf
      - ./pg-slave/pg_hba.conf:/etc/postgresql/pg_hba.conf
    command: postgres -c 'config_file=/etc/postgresql/postgresql.conf'
    networks:
      - pg-network
    depends_on:
      - pg-master
    restart: always

  pgpool:
    image: bitnami/pgpool:4
    container_name: pgpool
    environment:
      PGPOOL_ADMIN_USERNAME: admin
      PGPOOL_ADMIN_PASSWORD: admin123
      PGPOOL_POSTGRES_USERNAME: postgres
      PGPOOL_POSTGRES_PASSWORD: postgres123
      PGPOOL_BACKEND_NODES: 0:pg-master:5432,1:pg-slave1:5432,2:pg-slave2:5432
      PGPOOL_SR_CHECK_USER: postgres
      PGPOOL_SR_CHECK_PASSWORD: postgres123
      PGPOOL_ENABLE_LOAD_BALANCING: "yes"
      PGPOOL_ENABLE_STATEMENT_LOAD_BALANCING: "yes"
      PGPOOL_POSTGRES_CUSTOM_USERS: repl
      PGPOOL_POSTGRES_CUSTOM_PASSWORDS: replpass
    ports:
      - "5432:5432"
      - "9898:9898"
    networks:
      - pg-network
    depends_on:
      - pg-master
      - pg-slave1
      - pg-slave2
    restart: always

networks:
  pg-network:
    driver: bridge

volumes:
  pg-master-data:
  pg-slave1-data:
  pg-slave2-data:
```

## 4. PostgreSQL + Citus 分布式集群

Citus 是 PostgreSQL 的扩展，可以将数据库扩展到多个节点，实现水平扩展。

```yaml
version: '3.8'
services:
  citus-coordinator:
    image: citusdata/citus:11.0
    container_name: citus-coordinator
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
      POSTGRES_DB: appdb
    ports:
      - "5432:5432"
    volumes:
      - citus-coordinator-data:/var/lib/postgresql/data
    command: >
      postgres -c max_connections=100
               -c shared_buffers=1GB
               -c citus.shard_count=32
               -c citus.shard_replication_factor=1
    networks:
      - citus-network
    restart: always

  citus-worker-1:
    image: citusdata/citus:11.0
    container_name: citus-worker-1
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
      POSTGRES_DB: appdb
    volumes:
      - citus-worker-1-data:/var/lib/postgresql/data
    command: >
      postgres -c max_connections=100
               -c shared_buffers=1GB
    networks:
      - citus-network
    restart: always

  citus-worker-2:
    image: citusdata/citus:11.0
    container_name: citus-worker-2
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
      POSTGRES_DB: appdb
    volumes:
      - citus-worker-2-data:/var/lib/postgresql/data
    command: >
      postgres -c max_connections=100
               -c shared_buffers=1GB
    networks:
      - citus-network
    restart: always

networks:
  citus-network:
    driver: bridge

volumes:
  citus-coordinator-data:
  citus-worker-1-data:
  citus-worker-2-data:
```

**初始化步骤:**
1. 启动集群：
```bash
docker-compose up -d
```

2. 添加工作节点到协调器：
```bash
docker exec -it citus-coordinator psql -U postgres -d appdb -c "SELECT * FROM citus_add_node('citus-worker-1', 5432);"
docker exec -it citus-coordinator psql -U postgres -d appdb -c "SELECT * FROM citus_add_node('citus-worker-2', 5432);"
```

3. 验证节点状态：
```bash
docker exec -it citus-coordinator psql -U postgres -d appdb -c "SELECT * FROM citus_get_active_worker_nodes();"
```

## 各方案对比

| 集群类型 | 优点 | 缺点 | 适用场景 |
|---------|------|------|----------|
| 主从复制 | 配置简单，易于维护 | 主库单点故障，需手动切换 | 读写分离、数据备份 |
| Patroni + etcd | 自动故障转移，高可用 | 配置复杂，资源消耗大 | 企业级高可用场景 |
| PgPool-II | 连接池、负载均衡、故障转移 | 配置复杂，单点故障 | 读写分离、连接池管理 |
| Citus | 水平扩展，分布式查询 | 应用改造成本高 | 大规模数据处理、分析 |

## 注意事项

1. 生产环境中，建议将各节点部署在不同的物理机上
2. 密码和敏感信息应使用环境变量或 Docker secrets 管理
3. 数据卷应妥善备份
4. 网络配置应考虑安全性，避免直接暴露数据库端口
5. 集群初始化脚本应自动化，避免人工操作错误
