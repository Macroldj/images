FROM registry.cn-hangzhou.aliyuncs.com/macroldj/ubuntu:22.04-base

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt install net-tools -y && \
    apt install iputils-ping -y && \
    apt install iproute2 -y && \
    apt install netcat -y && \
    apt install dnsutils -y && \
    apt install traceroute -y && \
    apt install curl -y && \
    apt install wget -y && \
    apt install telnet -y && \
    apt install nmap -y && \
    apt install tcpdump -y

COPY ./script /app/script/
