# centos 7 

wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo

yum clean all
yum makecache
yum update -y

yum install -y epel-release

yum install -y drbd-utils kmod-drbd

systemctl start drbd

systemctl status drbd
### /etc/hostname
```
100.64.10.227 gitlab-node-1
100.64.10.229 gitlab-node-1
```

## /etc/drbd.d/global_common.conf
```
global {
    usage-count no;
}

common {
    handlers {
        fence-peer "/usr/lib/drbd/crm-fence-peer.sh";
        split-brain "/usr/lib/drbd/notify-split-brain.sh root";
    }

    startup {
        wfc-timeout  0;
        degr-wfc-timeout 120;
    }

    options {
        disk-barrier no;
        disk-flushes no;
        c-plan-ahead 0;
    }
}
```

## /etc/drbd.d/gitlab.res
