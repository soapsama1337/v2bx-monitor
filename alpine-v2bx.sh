#!/bin/sh
# ==========================================
# 专供 Alpine NAT/LXC 环境的 v2bx 守护一键安装包
# 采用 OpenRC + 无限循环架构，彻底抛弃 Cron
# ==========================================

echo "=> [1/4] 正在清理旧版本残留..."
rm -f /root/alpine-v2bx-core.sh /root/alpine-v2bx-loop.sh
kill -9 $(pgrep -f alpine-v2bx-loop) 2>/dev/null

echo "=> [2/4] 正在写入核心守护逻辑..."
cat > /root/alpine-v2bx-core.sh << 'EOF'
#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
if ! pgrep -x "v2bx" > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Watchdog] v2bx is down, restarting..." >> /var/log/v2bx_alpine_monitor.log
    /usr/bin/v2bx restart >> /var/log/v2bx_alpine_monitor.log 2>&1
fi
EOF
chmod +x /root/alpine-v2bx-core.sh

echo "=> [3/4] 正在构建抗干涉死循环引擎..."
cat > /root/alpine-v2bx-loop.sh << 'EOF'
#!/bin/sh
while true; do
    /bin/sh /root/alpine-v2bx-core.sh
    sleep 60
done
EOF
chmod +x /root/alpine-v2bx-loop.sh

echo "=> [4/4] 正在配置 OpenRC 开机自启..."
mkdir -p /etc/local.d
cat > /etc/local.d/alpine-v2bx.start << 'EOF'
#!/bin/sh
kill -9 $(pgrep -f alpine-v2bx-loop) 2>/dev/null
nohup /root/alpine-v2bx-loop.sh >/dev/null 2>&1 &
EOF
chmod +x /etc/local.d/alpine-v2bx.start

rc-update add local default >/dev/null 2>&1
/etc/local.d/alpine-v2bx.start

echo "✅ Alpine 专属版部署完美收官！"
