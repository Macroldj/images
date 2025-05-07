#!/bin/bash

# 系统异常检测脚本
# 用于检测系统中的异常情况，如异常进程、网络连接等

LOG_DIR="/var/log/cron"
ANOMALY_LOG="$LOG_DIR/anomaly_detection.log"
ALERT_FILE="$LOG_DIR/system_alerts.log"

# 确保日志目录存在
mkdir -p $LOG_DIR

# 获取当前时间
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# 记录异常检测开始
echo "========== 系统异常检测 - $CURRENT_TIME ==========" >> $ANOMALY_LOG

# 检查CPU使用率异常的进程
echo "CPU使用率异常的进程:" >> $ANOMALY_LOG
ps aux | sort -nr -k 3 | head -10 >> $ANOMALY_LOG

# 检查内存使用率异常的进程
echo "内存使用率异常的进程:" >> $ANOMALY_LOG
ps aux | sort -nr -k 4 | head -10 >> $ANOMALY_LOG

# 检查网络连接数异常
echo "网络连接状态统计:" >> $ANOMALY_LOG
netstat -ant | awk '{print $6}' | sort | uniq -c | sort -nr >> $ANOMALY_LOG

# 检查最近的登录尝试
echo "最近的登录尝试:" >> $ANOMALY_LOG
last -n 10 >> $ANOMALY_LOG 2>&1

# 检查失败的登录尝试
echo "失败的登录尝试:" >> $ANOMALY_LOG
grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10 >> $ANOMALY_LOG
grep "Failed password" /var/log/secure 2>/dev/null | tail -10 >> $ANOMALY_LOG

# 检查可疑的进程
echo "可疑的进程:" >> $ANOMALY_LOG
ps aux | grep -E '(bash -i|nc -l|netcat|ncat)' | grep -v grep >> $ANOMALY_LOG

# 检查异常的定时任务
echo "所有用户的定时任务:" >> $ANOMALY_LOG
for user in $(cut -f1 -d: /etc/passwd); do
    crontab -u $user -l 2>/dev/null | grep -v "^#" >> $ANOMALY_LOG
done

# 检查系统启动项
echo "系统启动项:" >> $ANOMALY_LOG
ls -la /etc/init.d/ >> $ANOMALY_LOG 2>&1
systemctl list-unit-files --type=service --state=enabled 2>/dev/null >> $ANOMALY_LOG

# 检查异常的网络连接
echo "异常的网络连接:" >> $ANOMALY_LOG
netstat -antup 2>/dev/null | grep -E '(ESTABLISHED|LISTEN)' | grep -v -E '(127.0.0.1|::1)' >> $ANOMALY_LOG

# 检查是否有异常的大文件最近创建
echo "最近创建的大文件 (>100MB):" >> $ANOMALY_LOG
find / -type f -size +100M -mtime -1 -exec ls -lh {} \; 2>/dev/null >> $ANOMALY_LOG

# 记录异常检测完成
echo "========== 系统异常检测完成 ==========" >> $ANOMALY_LOG
echo "" >> $ANOMALY_LOG

# 轮转当前日志
if [ -f "$ANOMALY_LOG" ] && [ $(stat -c %s "$ANOMALY_LOG" 2>/dev/null || stat -f %z "$ANOMALY_LOG") -gt 1048576 ]; then
    mv "$ANOMALY_LOG" "$ANOMALY_LOG.$(date +%Y%m%d%H%M%S)"
fi