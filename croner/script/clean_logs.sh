#!/bin/bash

# 日志清理脚本
# 用于定期清理系统中的日志文件，防止磁盘空间被占满

LOG_DIR="/var/log/cron"
CLEAN_LOG="$LOG_DIR/clean_logs.log"

# 确保日志目录存在
mkdir -p $LOG_DIR

# 获取当前时间
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# 记录日志清理开始
echo "========== 日志清理开始 - $CURRENT_TIME ==========" >> $CLEAN_LOG

# 定义要清理的日志目录列表
LOG_DIRS=(
    "/var/log"
    "/var/log/cron"
    # 可以添加更多的日志目录
)

# 定义日志文件的最大保留天数
MAX_DAYS=7

# 清理旧的日志文件
for dir in "${LOG_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "清理目录: $dir" >> $CLEAN_LOG
        
        # 查找并删除超过最大保留天数的.log文件
        find "$dir" -name "*.log" -type f -mtime +$MAX_DAYS -exec ls -lh {} \; >> $CLEAN_LOG 2>&1
        find "$dir" -name "*.log" -type f -mtime +$MAX_DAYS -delete
        
        # 查找并删除超过最大保留天数的.gz文件（通常是压缩的日志）
        find "$dir" -name "*.gz" -type f -mtime +$MAX_DAYS -exec ls -lh {} \; >> $CLEAN_LOG 2>&1
        find "$dir" -name "*.gz" -type f -mtime +$MAX_DAYS -delete
        
        # 查找并删除超过最大保留天数的.old文件
        find "$dir" -name "*.old" -type f -mtime +$MAX_DAYS -exec ls -lh {} \; >> $CLEAN_LOG 2>&1
        find "$dir" -name "*.old" -type f -mtime +$MAX_DAYS -delete
    else
        echo "目录不存在: $dir" >> $CLEAN_LOG
    fi
done

# 压缩大于100MB的日志文件
for dir in "${LOG_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "压缩大文件: $dir" >> $CLEAN_LOG
        find "$dir" -name "*.log" -type f -size +100M -not -name "*.gz" -exec gzip {} \; >> $CLEAN_LOG 2>&1
    fi
done

# 清理自身产生的日志，只保留最近的10个
if [ -d "$LOG_DIR" ]; then
    # 清理系统状态日志
    ls -t $LOG_DIR/system_status.log.* 2>/dev/null | tail -n +11 | xargs -r rm -f
    # 清理系统警报日志
    ls -t $LOG_DIR/system_alerts.log.* 2>/dev/null | tail -n +11 | xargs -r rm -f
    # 清理日志清理的日志
    ls -t $LOG_DIR/clean_logs.log.* 2>/dev/null | tail -n +11 | xargs -r rm -f
fi

# 记录清理后的磁盘使用情况
echo "清理后的磁盘使用情况:" >> $CLEAN_LOG
df -h | grep -v "tmpfs" >> $CLEAN_LOG

echo "========== 日志清理完成 ==========" >> $CLEAN_LOG
echo "" >> $CLEAN_LOG

# 轮转当前日志
for log_file in "$LOG_DIR/system_status.log" "$LOG_DIR/system_alerts.log" "$LOG_DIR/clean_logs.log"; do
    if [ -f "$log_file" ] && [ $(stat -c %s "$log_file" 2>/dev/null || stat -f %z "$log_file") -gt 1048576 ]; then
        mv "$log_file" "$log_file.$(date +%Y%m%d%H%M%S)"
    fi
done