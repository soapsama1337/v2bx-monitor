#!/bin/bash

# 检查 v2bx 服务状态
status=$(systemctl is-active v2bx)

# 如果状态不是 active (即显示“未运行”)
if [ "$status" != "active" ]; then
    # 记录带时间戳的日志，方便你这个大老板回头对账
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 节点崩溃，正在尝试重启..." >> /var/log/v2bx_monitor.log
    
    # 针对 NAT 机器优化：重启前释放一下内存缓存
    sync && echo 3 > /proc/sys/vm/drop_caches
    sleep 1
    
    # 执行重启指令 (对应你图片菜单里的 6 号命令)
    v2bx restart >> /var/log/v2bx_monitor.log 2>&1
fi
