#!/bin/sh
# 强制声明路径，LXC 容器下的 cron 环境变量极其匮乏
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 使用最底层的 pgrep 扫描进程，并直接调用绝对路径重启
if ! pgrep -x "v2bx" > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Watchdog] v2bx is down, restarting..." >> /var/log/v2bx_monitor.log
    /usr/bin/v2bx restart >> /var/log/v2bx_monitor.log 2>&1
fi
