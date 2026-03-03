#!/bin/sh
# ==========================================
# Alpine NAT 终极防卡死版 (加入异步启动与心跳探针)
# ==========================================

echo "=> [1/4] 清理战场..."
rm -f /root/alpine-v2bx-core.sh /root/alpine-v2bx-loop.sh
kill -9 $(pgrep -f alpine-v2bx-loop) 2>/dev/null
kill -9 $(pgrep -f alpine-v2bx-core) 2>/dev/null

echo "=> [2/4] 写入核心逻辑 (防阻塞拔管机制)..."
cat > /root/alpine-v2bx-core.sh << 'EOF'
#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
if ! pgrep -x "v2bx" > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Alpine-Watchdog] 进程掉线，执行异步冷启动..." >> /var/log/v2bx_alpine_monitor.log
    
    # 绝杀技 1：用 start 代替 restart，避免找不到进程报错
    # 绝杀技 2：用 nohup ... & 把它强制踢到后台，绝不让它阻塞循环！
    nohup /usr/bin/v2bx start >/dev/null 2>&1 &
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Alpine-Watchdog] 启动命令已发送，直接放行！" >> /var/log/v2bx_alpine_monitor.log
fi
EOF
chmod +x /root/alpine-v2bx-core.sh

echo "=> [3/4] 写入死循环引擎 (加入心跳探针)..."
cat > /root/alpine-v2bx-loop.sh << 'EOF'
#!/bin/sh
while true; do
    # 往 /tmp 写个时间，证明循环没死（心跳探针）
    echo "Engine is running - $(date '+%H:%M:%S')" > /tmp/watchdog_heartbeat.txt
    
    /bin/sh /root/alpine-v2bx-core.sh < /dev/null
    ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1
    sleep 10
done
EOF
chmod +x /root/alpine-v2bx-loop.sh

echo "=> [4/4] 配置 OpenRC 开机自启..."
mkdir -p /etc/local.d
cat > /etc/local.d/alpine-v2bx.start << 'EOF'
#!/bin/sh
kill -9 $(pgrep -f alpine-v2bx-loop) 2>/dev/null
setsid /bin/sh /root/alpine-v2bx-loop.sh >/dev/null 2>&1 < /dev/null &
EOF
chmod +x /etc/local.d/alpine-v2bx.start

rc-update add local default >/dev/null 2>&1
/etc/local.d/alpine-v2bx.start

echo "=========================================="
echo "✅ 异步防卡死版部署完成！"
echo "=========================================="
