#!/bin/bash
# 检查 v2bx 状态
if [ "$(systemctl is-active v2bx)" != "active" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 状态异常，执行 v2bx restart" >> /var/log/v2bx_monitor.log
    v2bx restart >> /var/log/v2bx_monitor.log 2>&1
fi
