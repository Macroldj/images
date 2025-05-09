# Rsync 同步方案

## 1. 说明

Rsync 是一个快速、多功能的远程文件复制/同步工具，可以通过 rsh 或 ssh 方式实现数据同步，支持本地复制、远程复制、数据更新等操作。

## 2. 安装

```shell
apt install rsync
```

## 3. 使用 Lsyncd+Rsync配置实现 文件同步

```shell
# 同步文件配置
cat /etc/lsyncd.conf 
```

```conf
uid = root
gid = root
use chroot = no
max connections = 10 
timeout = 900
ignore nonreadable = yes
log file=/var/log/rsyncd.log
pid file=/var/run/rsyncd.pid
lock file=/var/run/rsyncd.lock
dont compress=*.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2

[gitlab]
    comment=gitlab backup files
    path=/data/gitlab
    ignore errors=yes
    hosts allow=100.64.10.227
    auth users=rsync_backup
    secrets file=/etc/rsyncd.passwd
    list=false
    read only=false
    uid=root
    gid=root
    strict modes=yes
    ignore nonreadable=yes
    transfer logging=no
    
```

## 发送端配置
vim /etc/rsync_client.passwd

```conf
settings {
	logfile = "/var/log/lsyncd/lsyncd.log",
	statusFile = "/var/log/lsyncd/lsyncd.status",
	insist = true,
	statusInterval = 10
}

sync {
	default.rsync,
	source="/data/gitlab",
	target="rsync_backup@100.64.10.229::gitlab",
	rsync = {
			binary = "/usr/bin/rsync",
			archive = true,
			compress = true,
			verbose   = true,
			--delete =  true,
			 _extra = {"--password-file=/etc/rsync_client.passwd"}
	}
}
```