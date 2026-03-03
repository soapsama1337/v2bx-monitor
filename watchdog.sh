#!/bin/bash
# 检查 v2bx 进程是否存在 (这种方式不依赖 systemctl)
if ! pgrep -x "v2bx" > /dev/null; then
    # 记录日志
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 进程未运行，执行 v2bx restart..." >> /var/log/v2bx_monitor.log
    
    # 执行重启指令
    v2bx restart >> /var/log/v2bx_monitor.log 2>&1
fi
