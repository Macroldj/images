# 容器镜像仓库

这个仓库包含了各种常用的 Docker 容器镜像配置，用于快速部署和测试各种服务。

## 目录结构

```
/Users/durgin/workspace/devops/images/
├── database/                # 数据库相关镜像
│   ├── clickhouse/          # ClickHouse 数据库
│   ├── etcd/                # etcd 键值存储
│   ├── mysql/               # MySQL 数据库
│   │   └── cluster/         # MySQL 集群配置
│   └── redis/               # Redis 数据库
│       └── cluster/         # Redis 集群配置
└── network/                 # 网络相关镜像
    └── net-analog/          # 网络分析工具
```

## 数据库镜像

### MySQL

提供单机和集群部署方案，支持 NDB Cluster 高可用配置。

### Redis

包含单机部署和基于 Sentinel 的高可用集群配置。

### ClickHouse

提供单机和分布式集群部署方案，适用于大规模数据分析场景。

### etcd

包含单机和多节点集群配置，用于服务发现和配置管理。

## 网络工具

### net-analog

提供网络分析环境，包含多个容器节点和 DNS 服务器，用于模拟和测试网络通信场景。

## 使用方法

每个目录下都包含 `docker-compose.yaml` 文件，可以直接使用以下命令启动服务：

```bash
cd /path/to/service
docker-compose up -d
```

## 注意事项

- 所有镜像均使用阿里云镜像仓库 `registry.cn-hangzhou.aliyuncs.com/macroldj/`，确保国内环境快速下载
- 开发测试环境使用，生产环境请根据实际需求调整配置
- 数据持久化通过 Docker 卷实现，确保容器重启后数据不丢失

## 贡献指南

欢迎提交 Pull Request 或 Issue 来完善这个仓库。

## Reference
- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 官方文档](https://docs.docker.com/compose/)
- [Docker Hub](https://hub.docker.com/)
- [阿里云容器镜像服务](https://cr.console.aliyun.com/)
- [Docker Compose 文件参考](https://docs.docker.com/compose/compose-file/)
- [Dockerfile 参考](https://docs.docker.com/engine/reference/builder/)
- [Docker Compose 命令参考](https://docs.docker.com/compose/reference/)
- [Docker 命令参考](https://docs.docker.com/engine/reference/commandline/docker/)
- [Docker Compose 示例](https://docs.docker.com/compose/gettingstarted/)
- [dockerfiles](https://github.com/tianon/dockerfiles.git)
