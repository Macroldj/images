# Jenkins 高可用部署 Docker Compose 配置

Jenkins 是一个流行的持续集成和持续部署工具，为了确保其高可用性，我们可以使用 Docker Compose 来部署 Jenkins 主从架构。以下是一个完整的高可用 Jenkins 部署方案。

## 目录结构

首先，让我们创建以下目录结构：

```
/Users/durgin/workspace/devops/images/flow/jenkins/
├── docker-compose.yaml       # 主配置文件
├── jenkins-master/           # Jenkins 主节点配置
│   ├── Dockerfile            # 主节点 Dockerfile
│   └── plugins.txt           # 预安装插件列表
├── jenkins-agent/            # Jenkins 从节点配置
│   └── Dockerfile            # 从节点 Dockerfile
└── README.md                 # 说明文档
```

## Docker Compose 配置

以下是 `docker-compose.yaml` 文件的内容：

```yaml
version: '3.8'

services:
  jenkins-master:
    build: ./jenkins-master
    container_name: jenkins-master
    restart: always
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins-master-data:/var/jenkins_home
    environment:
      - JENKINS_OPTS="--prefix=/jenkins"
      - JAVA_OPTS="-Xmx2g -Djava.awt.headless=true"
    networks:
      - jenkins-network

  jenkins-agent1:
    build: ./jenkins-agent
    container_name: jenkins-agent1
    restart: always
    environment:
      - JENKINS_URL=http://jenkins-master:8080
      - JENKINS_AGENT_NAME=agent1
      - JENKINS_SECRET=agent-secret-key
    volumes:
      - jenkins-agent1-data:/var/jenkins_agent
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - jenkins-master
    networks:
      - jenkins-network

  jenkins-agent2:
    build: ./jenkins-agent
    container_name: jenkins-agent2
    restart: always
    environment:
      - JENKINS_URL=http://jenkins-master:8080
      - JENKINS_AGENT_NAME=agent2
      - JENKINS_SECRET=agent-secret-key
    volumes:
      - jenkins-agent2-data:/var/jenkins_agent
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - jenkins-master
    networks:
      - jenkins-network

  nginx:
    image: nginx:latest
    container_name: jenkins-nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - jenkins-master
    networks:
      - jenkins-network

volumes:
  jenkins-master-data:
  jenkins-agent1-data:
  jenkins-agent2-data:

networks:
  jenkins-network:
    driver: bridge
```

## Jenkins 主节点 Dockerfile

创建 `jenkins-master/Dockerfile` 文件：

```dockerfile
FROM jenkins/jenkins:lts

USER root

# 安装必要的工具
RUN apt-get update && \
    apt-get install -y apt-transport-https \
                       ca-certificates \
                       curl \
                       gnupg2 \
                       software-properties-common && \
    apt-get clean

# 安装 Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean

# 复制预安装插件列表
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# 预安装插件
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

USER jenkins
```

## Jenkins 从节点 Dockerfile

创建 `jenkins-agent/Dockerfile` 文件：

```dockerfile
FROM jenkins/inbound-agent:latest

USER root

# 安装必要的工具
RUN apt-get update && \
    apt-get install -y apt-transport-https \
                       ca-certificates \
                       curl \
                       gnupg2 \
                       software-properties-common \
                       git \
                       maven \
                       openjdk-11-jdk && \
    apt-get clean

# 安装 Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean

# 创建工作目录
RUN mkdir -p /var/jenkins_agent
WORKDIR /var/jenkins_agent

USER jenkins
```

## 预安装插件列表

创建 `jenkins-master/plugins.txt` 文件：

```
workflow-aggregator
git
docker-workflow
credentials-binding
pipeline-stage-view
blueocean
kubernetes
configuration-as-code
job-dsl
role-strategy
```

## Nginx 配置

创建 `nginx/conf.d/jenkins.conf` 文件：

```
upstream jenkins {
    server jenkins-master:8080;
}

server {
    listen 80;
    server_name jenkins.example.com;

    location / {
        proxy_pass http://jenkins;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }
}
```

## 高可用特性

1. **主从架构**：使用 Jenkins 主节点和多个从节点，实现任务分发和负载均衡
2. **数据持久化**：使用 Docker 卷保存 Jenkins 数据，确保容器重启后数据不丢失
3. **自动重启**：设置容器自动重启，确保服务持续可用
4. **负载均衡**：使用 Nginx 作为反向代理，可以扩展为多主节点架构
5. **资源隔离**：每个节点运行在独立的容器中，互不影响

## 使用说明

1. 创建上述文件和目录结构
2. 启动服务：
   ```bash
   cd /Users/durgin/workspace/devops/images/flow/jenkins
   docker-compose up -d
   ```
3. 访问 Jenkins：http://localhost:8080 或 http://jenkins.example.com（如果配置了域名）
4. 首次访问时，需要输入初始管理员密码：
   ```bash
   docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword
   ```
5. 按照向导完成 Jenkins 初始化设置
6. 在 Jenkins 管理界面中配置从节点连接

## 注意事项

- 生产环境中应配置 HTTPS，确保通信安全
- `JENKINS_SECRET` 应该使用安全的随机值，而不是示例中的固定值
- 根据实际需求调整 Java 内存参数和资源限制
- 定期备份 Jenkins 数据卷

## 扩展建议

- 添加 Prometheus 和 Grafana 进行监控
- 使用 ELK 或 Graylog 进行日志集中管理
- 考虑使用 Kubernetes 部署以获得更好的扩展性和自愈能力

## Reference
- [kubernetes-operator](https://github.com/jenkinsci/kubernetes-operator#)
