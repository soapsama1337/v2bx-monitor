#!/bin/sh
# ==========================================
# 专供 Alpine NAT/LXC 环境的 v2bx 守护一键安装包 (防休眠终极版)
# 采用 OpenRC + setsid 隔离，加入 Ping 心跳防止母鸡冻结容器
# ==========================================

echo "=> [1/4] 正在清理旧版本残留..."
rm -f /root/alpine-v2bx-core.sh /root/alpine-v2bx-loop.sh
kill -9 $(pgrep -f alpine-v2bx-loop) 2>/dev/null

echo "=> [2/4] 正在写入核心守护逻辑..."
cat > /root/alpine-v2bx-core.sh << 'EOF'
#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
if ! pgrep -x "v2bx" > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Alpine-Watchdog] v2bx is down, restarting..." >> /var/log/v2bx_alpine_monitor.log
    /usr/bin/v2bx restart < /dev/null >> /var/log/v2bx_alpine_monitor.log 2>&1
fi
EOF
chmod +x /root/alpine-v2bx-core.sh

echo "=> [3/4] 正在构建带『网络心跳』的死循环引擎..."
cat > /root/alpine-v2bx-loop.sh << 'EOF'
#!/bin/sh
while true; do
    /bin/sh /root/alpine-v2bx-core.sh < /dev/null
    
    # 绝杀技：向外网发送极小数据包，强行保持容器活跃，防止母鸡休眠
    ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1
    
    sleep 10
done
EOF
chmod +x /root/alpine-v2bx-loop.sh

echo "=> [4/4] 正在配置 OpenRC 开机自启..."
mkdir -p /etc/local.d
cat > /etc/local.d/alpine-v2bx.start << 'EOF'
#!/bin/sh
kill -9 $(pgrep -f alpine-v2bx-loop) 2>/dev/null
# 使用 setsid 彻底剥离 SSH 终端关联
setsid /bin/sh /root/alpine-v2bx-loop.sh >/dev/null 2>&1 < /dev/null &
EOF
chmod +x /etc/local.d/alpine-v2bx.start

# 激活 Alpine local 服务以支持开机自启
rc-update add local default >/dev/null 2>&1
/etc/local.d/alpine-v2bx.start

echo "=========================================="
echo "✅ Alpine 防休眠版部署完美收官！"
echo "已加入网络心跳包，彻底解决母鸡冻结容器的问题。"
echo "=========================================="
