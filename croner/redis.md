# redis cluster backup and restore

## backup
```sh
redis-cli --cluster save /tmp/redis-cluster.rdb
```
## restore
```sh
redis-cli --cluster restore /tmp/redis-cluster.rdb
```
