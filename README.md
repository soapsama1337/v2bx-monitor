# 🚀 V2bX-Monitor (NAT小鸡崩溃定时重启)

**V2bX 节点守护脚本** 是基于 Shell 编写的自动化运维工具，专为管理多个服务器节点而设计。它能实时监测 V2bX 服务状态，并在检测到崩溃或“未运行”时自动拉起，确保节点高可用。

---

### 🛡️ 技术栈
![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=flat-square&logo=linux&logoColor=black)
![V2bX](https://img.shields.io/badge/Backend-V2bX-blue?style=flat-square)

### 🌟 项目贡献
* **发起人**: Soapsama
* **项目初衷**: 专门解决 NAT 机器因内存瓶颈导致后端进程频繁崩溃需要手动点重启的问题

---

## ✨ 功能特性

* **⚡ 自动监控**: 每分钟检查一次 V2bX 服务状态，检测到“未运行”即刻触发重启。
* **☁️ NAT 优化**: 完美适配 OpenVZ/LXC 架构，已剔除会导致 `Read-only file system` 报错的内核指令。
* **🍃 轻量运行**: 脚本体积极小，几乎不占用 CPU 与内存资源，适合极低配置的 NAT 小鸡。
* **📜 日志追踪**: 详细记录每次重启的时间点，方便管理员进行故障排查。

---

## 🛠️ 环境要求

* **操作系统**: Ubuntu / Debian / Alpine (Linux 全环境支持)
* **核心依赖**: `crontab` (用于定时任务), `curl`
* **适用后端**: [wyx2685/V2bX](https://github.com/wyx2685/V2bX)

---

## 📦 安装与启动

### 一键安装 (推荐)
> **注意**: 该脚本会默认安装在 `/root/w.sh`，并自动添加每分钟运行一次的定时任务。

```bash
curl -sLk [https://raw.githubusercontent.com/soapsama1337/v2bx-monitor/main/watchdog.sh](https://raw.githubusercontent.com/soapsama1337/v2bx-monitor/main/watchdog.sh) -o /root/w.sh && chmod +x /root/w.sh && (crontab -l 2>/dev/null; echo "* * * * * /bin/bash /root/w.sh") | crontab - && /bin/bash /root/w.sh
