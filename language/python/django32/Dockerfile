FROM python:3.8.12-slim-buster
RUN sed -i 's/http\:\/\/deb.debian.org/https\:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list \
 && sed -i 's/http\:\/\/security.debian.org/https\:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list \
 && apt-get update \
  #  数据库依赖 mysql: (debian python-dev libmariadb-dev) (centos python-devel mysql-devel)
  #  数据库依赖 postgresql: libpq-dev
 && apt-get install -y curl gcc vim\
 && rm -rf /var/lib/apt/lists/*
WORKDIR /home/workspace
COPY . .
CMD ["/bin/bash"]