# 系统基础镜像

## 目的
1. 维护最基础的原始镜像。
2. 镜像的层级依赖都清晰可见，减少不透明、增强安全性。

## 构建使用
```bash
# ubuntu 
cd ubuntu
docker build -f Dockerfile-build-20 -t registry.cn-hangzhou.aliyuncs.com/macroldj/ubuntu:20.04-base .
docker build -f Dockerfile-build-22 -t registry.cn-hangzhou.aliyuncs.com/macroldj/ubuntu:22.04-base .
docker build -f Dockerfile-build-24 -t registry.cn-hangzhou.aliyuncs.com/macroldj/ubuntu:24.04-base .

# debian
cd debian
docker build -f Dockerfile-build-12 -t registry.cn-hangzhou.aliyuncs.com/macroldj/debian:12-base .

# centos7
cd centos
docker build -f Dockerfile-build-7 -t registry.cn-hangzhou.aliyuncs.com/macroldj/centos:7-base .
```