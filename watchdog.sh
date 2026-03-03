#!/bin/bash

# 检查 v2bx 进程是否存在 (不依赖 systemctl，全平台通用)
if ! pgrep -x "v2bx" > /dev/null; then
    # 记录带时间戳的日志
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 进程消失，正在尝试重启..." >> /var/log/v2bx_monitor.log
    
    # 执行重启指令 (调用 v2bx 自身的脚本逻辑)
    v2bx restart >> /var/log/v2bx_monitor.log 2>&1
fi
