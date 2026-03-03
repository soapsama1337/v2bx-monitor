#!/bin/sh
# ==========================================
# 专供 Alpine NAT/LXC 环境的 v2bx 守护一键安装包 (终极防阻塞版)
# 采用 OpenRC + setsid 彻底隔离终端会话，解决挂起与休眠问题
# ==========================================

echo "=> [1/4] 正在清理旧版本残留..."
rm -f /root/alpine-v2bx-core.sh /root/alpine-v2bx-loop.sh
kill -9 $(pgrep -f alpine-v2bx-loop) 2>/dev/null

echo "=> [2/4] 正在写入核心守护逻辑 (切断标准输入)..."
cat > /root/alpine-v2bx-core.sh << 'EOF'
#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
if ! pgrep -x "v2bx" > /dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [Alpine-Watchdog] v2bx is down, restarting..." >> /var/log/v2bx_alpine_monitor.log
    # 关键点：使用 < /dev/null 确保它绝不会等待键盘输入
    /usr/bin/v2bx restart < /dev/null >> /var/log/v2bx_alpine_monitor.log 2>&1
fi
EOF
chmod +x /root/alpine-v2bx-core.sh

echo "=> [3/4] 正在构建防挂起死循环引擎 (15秒极速巡查)..."
cat > /root/alpine-v2bx-loop.sh << 'EOF'
#!/bin/sh
while true; do
    /bin/sh /root/alpine-v2bx-core.sh < /dev/null
    sleep 15
done
EOF
chmod +x /root/alpine-v2bx-loop.sh

echo "=> [4/4] 正在配置 OpenRC 开机自启 (使用 setsid 会话隔离)..."
mkdir -p /etc/local.d
cat > /etc/local.d/alpine-v2bx.start << 'EOF'
#!/bin/sh
kill -9 $(pgrep -f alpine-v2bx-loop) 2>/dev/null
# 绝杀技：使用 setsid 彻底剥离 SSH 终端关联，沉入系统底层
setsid /bin/sh /root/alpine-v2bx-loop.sh >/dev/null 2>&1 < /dev/null &
EOF
chmod +x /etc/local.d/alpine-v2bx.start

# 激活 Alpine local 服务以支持开机自启
rc-update add local default >/dev/null 2>&1
# 立即启动守护
/etc/local.d/alpine-v2bx.start



echo "=========================================="
echo "✅ Alpine 终极隔离版部署完美收官！"
echo "守护进程已沉入系统最底层，免疫终端阻塞和 SSH 断开。"
echo "请进行盲测：执行 v2bx stop，然后手离开键盘等待 30 秒。"
echo "=========================================="
