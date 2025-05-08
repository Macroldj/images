# MongoDB集群搭建

# 单机版链接地址
```shell
mongodb://admin:admin123@100.64.17.45:27017/
```

# 集群版链接地址
```shell
mongodb://admin:admin123@100.64.17.45:27017,100.64.17.45:27018,100.64.17.45:27019/?replicaSet=rs0
```

## 集群版自动化注册之后会导致无法登录
```shell
# 解决方法
use admin
db.auth('admin','admin123')
cfg = rs.conf()
cfg.members[0].host = "100.64.17.45:27017"
cfg.members[1].host = "100.64.17.45:27018"
cfg.members[2].host = "100.64.17.45:27019"
rs.reconfig(cfg, {force: true})
```

## 问题排查
```shell
docker exec -it mongo mongosh -u admin -p admin123 --authenticationDatabase admin

rs.status()

rs.conf()
```