#!/bin/bash

# HTTP事件上传脚本
# 用于收集系统信息并上传到事件中心

LOG_DIR="/var/log/cron"
UPLOAD_LOG="$LOG_DIR/event_upload.log"

# 确保日志目录存在
mkdir -p $LOG_DIR

# 获取当前时间
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
TIMESTAMP=$(date +%s)

# 记录上传开始
echo "========== 事件上传开始 - $CURRENT_TIME ==========" >> $UPLOAD_LOG

# 事件中心API地址
EVENT_CENTER_URL="http://your-event-center-api.com/events"
# 如果需要认证，可以设置认证令牌
AUTH_TOKEN="your-auth-token"

# 收集系统信息
HOST_NAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
UPTIME=$(uptime -s)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEM_INFO=$(free -m | grep Mem)
MEM_TOTAL=$(echo $MEM_INFO | awk '{print $2}')
MEM_USED=$(echo $MEM_INFO | awk '{print $3}')
MEM_USAGE_PERCENT=$(awk "BEGIN {printf \"%.2f\", $MEM_USED/$MEM_TOTAL*100}")
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
LOAD_AVG=$(cat /proc/loadavg | awk '{print $1, $2, $3}')

# 检查是否有系统警报
if [ -f "$LOG_DIR/system_alerts.log" ]; then
    ALERTS=$(tail -n 10 "$LOG_DIR/system_alerts.log")
else
    ALERTS="No alerts found"
fi

# 创建JSON数据
JSON_DATA=$(cat << EOF
{
  "timestamp": $TIMESTAMP,
  "host": "$HOST_NAME",
  "ip": "$IP_ADDRESS",
  "metrics": {
    "uptime": "$UPTIME",
    "cpu_usage": $CPU_USAGE,
    "memory_usage": $MEM_USAGE_PERCENT,
    "disk_usage": $DISK_USAGE,
    "load_average": "$LOAD_AVG"
  },
  "alerts": $(echo "$ALERTS" | jq -R -s '.')
}
EOF
)

echo "准备上传的数据:" >> $UPLOAD_LOG
echo "$JSON_DATA" >> $UPLOAD_LOG

# 上传数据到事件中心
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d "$JSON_DATA" \
  "$EVENT_CENTER_URL" 2>&1)

# 检查上传结果
if [ $? -eq 0 ]; then
    echo "上传成功! 响应:" >> $UPLOAD_LOG
    echo "$RESPONSE" >> $UPLOAD_LOG
else
    echo "上传失败! 错误:" >> $UPLOAD_LOG
    echo "$RESPONSE" >> $UPLOAD_LOG
fi

echo "========== 事件上传完成 ==========" >> $UPLOAD_LOG
echo "" >> $UPLOAD_LOG

# 轮转当前日志
if [ -f "$UPLOAD_LOG" ] && [ $(stat -c %s "$UPLOAD_LOG" 2>/dev/null || stat -f %z "$UPLOAD_LOG") -gt 1048576 ]; then
    mv "$UPLOAD_LOG" "$UPLOAD_LOG.$(date +%Y%m%d%H%M%S)"
fi