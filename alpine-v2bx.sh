#!/bin/sh
# ==========================================
# Alpine NAT 终极完全体 (修复进程名大小写匹配 BUG)
# ==========================================

echo "=> [1/4] 清理战场..."
rm -f /root/alpine-v2bx-core.sh /root/alpine-v2bx-loop.sh
kill -9 $(pgrep -f alpine-v2bx-loop) 2>/dev/null
kill -9 $(pgrep -f alpine-v2bx-core) 2>/dev/null

echo "=> [2/4] 写入核心逻辑 (模糊匹配进程名)..."
cat > /root/alpine-v2bx-core.sh << 'EOF'
#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 绝杀技：使用 ps 和 grep -i 进行忽略大小写的模糊匹配！
# grep -v "alpine-v2bx" 是为了防止脚本查到自己。
if ! ps w | grep -v "grep" | grep -v "alpine-v2bx" | grep -i "v2bx" > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Alpine-Watchdog] 发现进程掉线，执行启动..." >> /var/log/v2bx_alpine_monitor.log
    
    # 既然测试证明启动命令不阻塞，直接正常执行即可
    /usr/bin/v2bx start >> /var/log/v2bx_alpine_monitor.log 2>&1
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Alpine-Watchdog] 启动命令执行完毕！" >> /var/log/v2bx_alpine_monitor.log
fi
EOF
chmod +x /root/alpine-v2bx-core.sh

echo "=> [3/4] 写入死循环引擎 (心跳探针)..."
cat > /root/alpine-v2bx-loop.sh << 'EOF'
#!/bin/sh
while true; do
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
echo "✅ Alpine 终极完美形态部署完成！"
echo "=========================================="
