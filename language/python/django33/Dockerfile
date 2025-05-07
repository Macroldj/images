FROM 192.168.9.37/devops/python:3.10.16-slim-bullseye

RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone

RUN sed -i 's/http\:\/\/deb.debian.org/https\:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list \
 && sed -i 's/http\:\/\/security.debian.org/https\:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y curl gcc vim libpq-dev\
 && rm -rf /var/lib/apt/lists/*

WORKDIR /home/workspace
ADD ./requirements.txt /tmp/requirements.txt
RUN pip3 install --upgrade pip -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
RUN pip3 install --no-cache-dir  -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com \
                                 -r /tmp/requirements.txt && rm -rf /tmp/requirements.txt
