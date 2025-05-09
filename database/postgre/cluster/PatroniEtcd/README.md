# Patroni + etcd + HAProxy

是一种高度自动化的高可用（HA）集群解决方案，它结合了分布式协调、故障转移和负载均衡能力。以下是该架构的核心原理、
部署步骤及关键配置说明：

### **1. 架构组成及角色**
| 组件          | 角色描述                                    |
|-------------|-----------------------------------------|
| **Patroni** | 管理 PostgreSQL 实例的生命周期，处理主备切换、配置同步和健康检查。 |
| **etcd**    | 分布式键值存储，保存集群状态（如主节点信息），实现节点间的状态一致性。     |
| **HAProxy** | 流量代理层，将读写请求路由到主节点，只读请求分发到备节点（负载均衡）。     |

---

### **2. 典型部署架构**
```
+-----------------+       +-----------------+       +-----------------+
|   PostgreSQL    |       |   PostgreSQL    |       |   PostgreSQL    |
|    Node 1       |       |    Node 2       |       |    Node 3       |
| (Primary)       |       | (Standby)       |       | (Standby)       |
| Patroni + etcd  |<----->| Patroni + etcd  |<----->| Patroni + etcd  |
+-----------------+       +-----------------+       +-----------------+
          ↑                      ↑                      ↑
          |                      |                      |
          +----------------------+----------------------+
                               |
                          +-----+-----+
                          |  HAProxy  |
                          | (VIP: 10.0.0.100) |
                          +-----+-----+
                                ↓
                         +------+------+
                         | Application |
                         +-------------+
```

---

### **3. 关键组件配置步骤**

#### **(1) 部署 etcd 集群**
- **目标**：构建一个 3 节点的 etcd 集群（奇数节点防止脑裂）。
- **配置示例**（每个节点）：
  ```bash
  # etcd 配置文件 /etc/etcd/etcd.conf
  name: etcd-node1
  data-dir: /var/lib/etcd
  listen-client-urls: http://0.0.0.0:2379
  advertise-client-urls: http://<NODE_IP>:2379
  initial-cluster: etcd-node1=http://<NODE1_IP>:2380,etcd-node2=http://<NODE2_IP>:2380,etcd-node3=http://<NODE3_IP>:2380
  initial-cluster-token: etcd-cluster-1
  initial-cluster-state: new
  ```
- **启动 etcd**：
  ```bash
  systemctl start etcd
  ```

#### **(2) 配置 Patroni 管理 PostgreSQL**
- **安装 Patroni**：
  ```bash
  pip install patroni[etcd]
  ```
- **Patroni 配置文件** (`/etc/patroni.yml`)：
  ```yaml
  scope: pg-cluster  # 集群名称
  namespace: /service/
  name: node1        # 当前节点名称

  restapi:
    listen: 0.0.0.0:8008
    connect_address: <NODE_IP>:8008

  etcd:
    hosts: ["<ETCD_NODE1_IP>:2379", "<ETCD_NODE2_IP>:2379", "<ETCD_NODE3_IP>:2379"]

  bootstrap:
    dcs:
      ttl: 30
      loop_wait: 10
      retry_timeout: 10
      postgresql:
        use_pg_rewind: true
        parameters:
          wal_level: replica
          hot_standby: "on"
          max_connections: 100
    initdb:
    - encoding: UTF8
    - locale: en_US.UTF-8
    pg_hba:
    - host replication replicator 0.0.0.0/0 md5
    - host all all 0.0.0.0/0 md5

  postgresql:
    listen: 0.0.0.0:5432
    connect_address: <NODE_IP>:5432
    data_dir: /var/lib/postgresql/12/main
    bin_dir: /usr/lib/postgresql/12/bin
    authentication:
      replication:
        username: replicator
        password: securepassword
      superuser:
        username: postgres
        password: adminpassword

  tags:
    nofailover: false
    noloadbalance: false
  ```
- **启动 Patroni**：
  ```bash
  patroni /etc/patroni.yml
  ```

#### **(3) 配置 HAProxy 实现流量路由**
- **HAProxy 配置文件** (`/etc/haproxy/haproxy.cfg`)：
  ```cfg
  global
      log /dev/log local0
      maxconn 100

  defaults
      log global
      mode tcp
      timeout connect 5s
      timeout client 30s
      timeout server 30s

  frontend pg_write
      bind *:5000
      default_backend pg_primary

  frontend pg_read
      bind *:5001
      default_backend pg_replicas

  backend pg_primary
      option httpchk GET /primary
      http-check expect status 200
      server node1 <NODE1_IP>:5432 check port 8008 inter 5s rise 2 fall 3
      server node2 <NODE2_IP>:5432 check port 8008 inter 5s rise 2 fall 3
      server node3 <NODE3_IP>:5432 check port 8008 inter 5s rise 2 fall 3

  backend pg_replicas
      balance roundrobin
      option httpchk GET /replica
      http-check expect status 200
      server node1 <NODE1_IP>:5432 check port 8008 inter 5s rise 2 fall 3
      server node2 <NODE2_IP>:5432 check port 8008 inter 5s rise 2 fall 3
      server node3 <NODE3_IP>:5432 check port 8008 inter 5s rise 2 fall 3
  ```
- **启动 HAProxy**：
  ```bash
  systemctl restart haproxy
  ```

---

### **4. 故障转移流程**
1. **主节点宕机**：
    - Patroni 检测到主节点不可用（通过 etcd 心跳超时）。
2. **选举新主**：
    - etcd 协调剩余节点，选择优先级最高的备节点提升为新主。
3. **流量切换**：
    - HAProxy 通过健康检查（HTTP 接口 `/primary`）自动将写流量指向新主节点。
4. **旧主恢复**：
    - 旧主节点重新加入集群，自动成为备节点并同步数据。

---

### **5. 生产环境最佳实践**
- **同步复制配置**：
  ```yaml
  # 在 Patroni 的 bootstrap.dcs 中配置同步节点
  synchronous_mode: true
  synchronous_node_count: 1  # 至少一个备节点确认写入
  ```
- **监控与告警**：
    - 使用 Prometheus + Grafana 监控 Patroni、etcd 和 HAProxy 状态。
    - 关键指标：`patroni_primary`, `etcd_server_has_leader`, `haproxy_backend_status`.
- **定期测试故障转移**：
  ```bash
  patronictl failover --force pg-cluster
  ```

---

### **6. 常见问题**
- **脑裂风险**：确保 etcd 集群为奇数节点，避免网络分区。
- **HAProxy 单点**：部署多 HAProxy 实例，结合 Keepalived 实现 VIP 漂移。
- **数据一致性**：优先使用同步复制（`synchronous_mode: true`）。
