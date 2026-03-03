#!/bin/bash

# 检查 v2bx 状态
status=$(systemctl is-active v2bx)

# 如果状态不是 active
if [ "$status" != "active" ]; then
    # 记录时间戳日志
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 状态异常，执行 v2bx restart" >> /var/log/v2bx_monitor.log
    
    # 删掉了会导致报错的内存清理命令，直接执行重启
    v2bx restart >> /var/log/v2bx_monitor.log 2>&1
fi
