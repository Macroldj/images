#!/bin/bash

# 系统状态检查脚本
# 用于检查系统的CPU、内存、磁盘使用情况等

LOG_DIR="/var/log/cron"
LOG_FILE="$LOG_DIR/system_status.log"
ALERT_FILE="$LOG_DIR/system_alerts.log"

# 确保日志目录存在
mkdir -p $LOG_DIR

# 获取当前时间
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# 记录系统状态开始
echo "========== 系统状态检查 - $CURRENT_TIME ==========" >> $LOG_FILE

# 检查CPU使用率
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
echo "CPU使用率: $CPU_USAGE%" >> $LOG_FILE

# 检查内存使用情况
MEM_INFO=$(free -m | grep Mem)
MEM_TOTAL=$(echo $MEM_INFO | awk '{print $2}')
MEM_USED=$(echo $MEM_INFO | awk '{print $3}')
MEM_FREE=$(echo $MEM_INFO | awk '{print $4}')
MEM_USAGE_PERCENT=$(awk "BEGIN {printf \"%.2f\", $MEM_USED/$MEM_TOTAL*100}")

echo "内存总量: $MEM_TOTAL MB" >> $LOG_FILE
echo "内存使用: $MEM_USED MB" >> $LOG_FILE
echo "内存剩余: $MEM_FREE MB" >> $LOG_FILE
echo "内存使用率: $MEM_USAGE_PERCENT%" >> $LOG_FILE

# 检查磁盘使用情况
echo "磁盘使用情况:" >> $LOG_FILE
df -h | grep -v "tmpfs" >> $LOG_FILE

# 检查系统负载
LOAD_AVG=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
echo "系统负载 (1分钟, 5分钟, 15分钟): $LOAD_AVG" >> $LOG_FILE

# 检查进程数量
PROCESS_COUNT=$(ps aux | wc -l)
echo "当前进程数量: $PROCESS_COUNT" >> $LOG_FILE

# 检查系统运行时间
UPTIME=$(uptime -p)
echo "系统运行时间: $UPTIME" >> $LOG_FILE

# 检查异常情况并发出警报
# 设置阈值
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=85

# 检查CPU是否超过阈值
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    echo "[$CURRENT_TIME] 警告: CPU使用率 ($CPU_USAGE%) 超过阈值 ($CPU_THRESHOLD%)" >> $ALERT_FILE
fi

# 检查内存是否超过阈值
if (( $(echo "$MEM_USAGE_PERCENT > $MEM_THRESHOLD" | bc -l) )); then
    echo "[$CURRENT_TIME] 警告: 内存使用率 ($MEM_USAGE_PERCENT%) 超过阈值 ($MEM_THRESHOLD%)" >> $ALERT_FILE
fi

# 检查磁盘是否超过阈值
df -h | grep -v "tmpfs" | awk '{print $5, $6}' | while read usage mount; do
    usage_percent=${usage%\%}
    if [ "$usage_percent" -gt "$DISK_THRESHOLD" ]; then
        echo "[$CURRENT_TIME] 警告: 磁盘 $mount 使用率 ($usage) 超过阈值 ($DISK_THRESHOLD%)" >> $ALERT_FILE
    fi
done

echo "========== 系统状态检查完成 ==========" >> $LOG_FILE
echo "" >> $LOG_FILE

# 如果有异常情况，可以在这里添加发送邮件或其他通知的代码