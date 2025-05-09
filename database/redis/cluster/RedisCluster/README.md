# redis-cluster deploy 
```shell
docker-compose up -d
```
### 同机器部署方式
redis 和 游戏服在一起执行下面的命令， 然后填 yes
```shell
docker exec -it redis-cluster-2 redis-cli --cluster create 100.64.x.x:26379 100.64.x.x:26380 100.64..x.x:26381 --cluster-replicas 0
docker exec -it redis-cluster-2 redis-cli --cluster create 127.0.0.1:26379 127.0.0.1:26380 127.0.0.1:26381 127.0.0.1:26382 127.0.0.1:26383 127.0.0.1:26384 --cluster-replicas 1
```

### 非同机器部署方式
如果redis-cluster和游戏服不在一起填redis所在的IP地址 100.64.x.x，然后执行下面的命令， 然后填 yes
```shell
docker exec -it redis-cluster-2 redis-cli --cluster create 100.64.x.x:26379 100.64.x.x:26380 100.64..x.x:26381 --cluster-replicas 0
```

```shell
docker exec -it redis-cluster-2 redis-cli --cluster create 100.64.22.140:26379 100.64.22.140:26380 100.64.22.140:26381 100.64.22.140:26382 100.64.22.140:26383 100.64.22.140:26384 --cluster-replicas 1
docker exec -it redis-cluster-2 redis-cli --cluster create 100.64.17.45:26379 100.64.17.45:26380 100.64.17.45:26381 100.64.17.45:26382 100.64.17.45:26383 100.64.17.45:26384 --cluster-replicas 1
docker exec -it redis-cluster-2 redis-cli --cluster create 100.64.17.45:26379 100.64.17.45:26380 100.64.17.45:26381 --cluster-replicas 0
```

### 当前使用init
```shell
docker-compose -f docker-compose-relpace-1.yaml up -d 
docker-compose -f docker-compose-relpace-2.yaml up -d 
```