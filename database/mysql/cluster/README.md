# MySQL 集群部署方案详解

MySQL 作为一种流行的关系型数据库，有多种集群部署方式，下面详细介绍几种常见的集群部署方案及其 Docker Compose 配置。

## 1. 主从复制（Master-Slave Replication）

主从复制是最基础的 MySQL 高可用方案，适用于读写分离、数据备份场景。

**初始化步骤:**
1. 在主库创建复制用户：
```sql
CREATE USER 'repl'@'%' IDENTIFIED BY 'repl123';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
```

2. 获取主库状态：
```sql
SHOW MASTER STATUS;
```

3. 在从库配置复制：
```sql
CHANGE MASTER TO
  MASTER_HOST='mysql-master',
  MASTER_USER='repl',
  MASTER_PASSWORD='repl123',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=157;
START SLAVE;
```

## 2. MySQL InnoDB Cluster (MGR)

MySQL InnoDB Cluster 基于 Group Replication，提供自动故障转移和高可用性。


**初始化步骤:**
1. 在每个节点创建复制用户：
```sql
SET SQL_LOG_BIN=0;
CREATE USER 'repl'@'%' IDENTIFIED BY 'repl123';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='repl', MASTER_PASSWORD='repl123' FOR CHANNEL 'group_replication_recovery';
```

2. 在第一个节点启动组复制：
```sql
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
```

3. 在其他节点启动组复制：
```sql
START GROUP_REPLICATION;
```

## 3. MySQL NDB Cluster

NDB Cluster 是 MySQL 的分布式集群解决方案，提供高可用性和可扩展性。

## 4. ProxySQL + MySQL 读写分离集群

ProxySQL 可以实现 MySQL 的读写分离和负载均衡。

## 各方案对比

| 集群类型             | 优点         | 缺点           | 适用场景        |
|------------------|------------|--------------|-------------|
| 主从复制             | 配置简单，易于维护  | 主库单点故障，需手动切换 | 读写分离、数据备份   |
| InnoDB Cluster   | 自动故障转移，高可用 | 配置复杂，资源消耗大   | 企业级高可用场景    |
| NDB Cluster      | 高性能，分布式存储  | 配置复杂，资源消耗大   | 大规模分布式应用    |
| ProxySQL + MySQL | 读写分离，负载均衡  | 需额外维护代理层     | 需要灵活读写分离的场景 |

## 注意事项

1. 生产环境中，建议将各节点部署在不同的物理机上
2. 密码和敏感信息应使用环境变量或 Docker secrets 管理
3. 数据卷应妥善备份
4. 网络配置应考虑安全性，避免直接暴露数据库端口
5. 集群初始化脚本应自动化，避免人工操作错误