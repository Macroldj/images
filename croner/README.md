# croner 

## 描述

这是一个基于Docker的定时任务处理器，主要用于以下功能：

1. 系统状态检查：监控CPU、内存、磁盘使用情况等
2. 日志清理：定期清理系统日志，防止磁盘空间被占满
3. 系统异常检测：检测系统中的异常情况，如异常进程、网络连接等
4. 事件上传：将系统信息通过HTTP上传到事件中心
5. 定时任务执行：使用cron定时执行上述脚本

## 目录结构
```shell
croner/
  Dockerfile-build-kalirolling-20        - Docker镜像构建文件
  README.md         - 说明文档
  script/
    check_sys.sh    - 系统状态检查脚本
    clean_logs.sh   - 日志清理脚本
    detect_anomaly.sh - 系统异常检测脚本
    upload_events.sh  - HTTP事件上传脚本
```
## 使用方法

### 构建Docker镜像

```bash
cd /path/to/croner
docker build -t croner:latest .
```

### 运行容器

```bash
docker run -d --name croner \
  --restart=always \
  --privileged \
  -v /var/log:/host/var/log \
  -e EVENT_CENTER_URL="http://your-event-center-api.com/events" \
  -e AUTH_TOKEN="your-auth-token" \
  croner:latest
```

### 查看日志

```bash
# 查看系统状态日志
docker exec croner cat /var/log/cron/system_status.log

# 查看系统警报日志
docker exec croner cat /var/log/cron/system_alerts.log

# 查看日志清理日志
docker exec croner cat /var/log/cron/clean_logs.log

# 查看异常检测日志
docker exec croner cat /var/log/cron/anomaly_detection.log

# 查看事件上传日志
docker exec croner cat /var/log/cron/event_upload.log
```

### 手动执行脚本

```bash
# 手动执行系统状态检查
docker exec croner /usr/local/bin/check_sys.sh

# 手动执行日志清理
docker exec croner /usr/local/bin/clean_logs.sh

# 手动执行系统异常检测
docker exec croner /usr/local/bin/detect_anomaly.sh

# 手动执行事件上传
docker exec croner /usr/local/bin/upload_events.sh
```

## 定时任务配置

- 系统状态检查：每5分钟执行一次
- 日志清理：每天凌晨3点执行
- 系统异常检测：每小时执行一次
- 事件上传：每10分钟执行一次

## 自定义配置

如需自定义定时任务的执行时间或其他配置，可以修改Dockerfile中的cron任务配置，然后重新构建镜像。

### 事件中心配置

在运行容器时，可以通过环境变量设置事件中心的URL和认证令牌：

- `EVENT_CENTER_URL`: 事件中心的API地址
- `AUTH_TOKEN`: 认证令牌

也可以直接修改`upload_events.sh`脚本中的相关配置。

## 注意事项

1. 容器需要以特权模式运行，以便能够访问主机的系统信息
2. 建议将主机的日志目录挂载到容器中，以便能够清理主机的日志文件
3. 在生产环境中使用时，建议根据实际需求调整脚本和定时任务的配置
4. 确保事件中心的API地址和认证令牌正确，否则事件上传可能会失败
```

## 使用说明

1. 首先，您需要修改`upload_events.sh`脚本中的`EVENT_CENTER_URL`和`AUTH_TOKEN`变量，设置为您的事件中心API地址和认证令牌。

2. 构建Docker镜像：
   ```bash
   cd /Users/durgin/workspace/devops/images/croner
   docker build -t croner:latest .
   ```

3. 运行容器：
   ```bash
   docker run -d --name croner \
     --restart=always \
     --privileged \
     -v /var/log:/host/var/log \
     -e EVENT_CENTER_URL="http://your-event-center-api.com/events" \
     -e AUTH_TOKEN="your-auth-token" \
     croner:latest
   ```

4. 脚本将每10分钟收集一次系统信息，并通过HTTP POST请求将数据上传到您的事件中心。

5. 您可以通过查看`/var/log/cron/event_upload.log`日志文件来监控上传情况。

## 自定义

如果您需要上传更多的系统信息，可以修改`upload_events.sh`脚本中的JSON数据结构，添加更多的字段。您也可以调整上传的频率，修改Dockerfile中的cron任务配置。

希望这个HTTP事件上传脚本能够满足您的需求！

