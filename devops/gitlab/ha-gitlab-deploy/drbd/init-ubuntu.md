# Ubuntu 初始化 gitlab 部署 drbd

```shell
# backup sources.list
cp -rf /etc/apt/sources.list /etc/apt/sources.list.bak
```

```shell
# update sources.list
deb https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse

# deb https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
```

```shell
# update apt
apt update 
```

```shell
systemctl start drbd
systemctl status drbd
systemctl enable drbd
systemctl restart drbd
```

# 主备节点切换
```shell
drbdadm  primary gitlab
drbdadm  secondary gitlab'
mount /dev/drbd0 /data
```
1. 主节点预计要切换到备节点
```shell
drbdadm  secondary gitlab
drbdadm  primary gitlab
```
2. 主节点宕机需要切换到备节点
```shell
node 1: 
drbdadm  secondary gitlab
node 2:
drbdadm  primary gitlab
```
3. 备节点宕机需要切换到主节点
```shell
node 1:
drbdadm  primary gitlab
node 2:
drbdadm  secondary gitlab
```

# docker gitlab
```shell
sudo docker run --detach \
  --hostname gitlab.cd.jjmatch.cn  \
  --publish 443:443 --publish 80:80 \
  --name gitlabnew \
  --restart always \
  --volume /data/gitlab/config:/etc/gitlab \
  --volume /data/gitlab/logs:/var/log/gitlab \
  --volume /data/gitlab/data:/var/opt/gitlab \
  --volume /etc/localtime:/etc/localtime:ro \
  100.64.10.37/devops/gitlab/gitlab-ce:14.7.3-ce.0
```

# /etc/docker/daemon.json
```json
{
  "insecure-registries": ["http://47.95.38.64","100.64.10.37","192.168.9.37","harbor-push.mgr.jjweb.cn","harbor-pull.mgr.jjweb.cn","hub.docker.com"]
}
```

```shell
systemctl daemon-reload
systemctl restart docker
```

root / JUflaKDMfhtoPFB

## 问题
1. drbd 挂载目录 取消挂载问题 umount /data umount: /data: target is busy. kill -9 PID 能解决占用磁盘的进程，不知道是否会有数据丢失。测试的几次没有问题。
2. ubuntu 重启后，系统自己进不了系统，需要系统部的配置之后才能进入，需要定位问题。
