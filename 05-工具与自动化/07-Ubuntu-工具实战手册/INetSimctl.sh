#!/usr/bin/env bash

set -euo pipefail

INETSIM_BIN="/usr/bin/inetsim"
CONFIG_FILE="/etc/inetsim/inetsim.conf"
PID_FILE="/var/run/inetsim.pid"
LOG_DIR="/var/log/inetsim"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONSOLE_LOG="${SCRIPT_DIR}/console.log"

BIND_ADDRESS="101.101.101.129"

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'

#########################################
# 通用函数
#########################################

is_running() {

    if [[ -f "${PID_FILE}" ]]; then

        local pid
        pid=$(cat "${PID_FILE}" 2>/dev/null || true)

        if [[ -n "${pid}" ]] &&
           kill -0 "${pid}" 2>/dev/null; then
            return 0
        fi
    fi

    pgrep -x inetsim_main >/dev/null 2>&1
}

show_header() {

    echo
    echo "============================================================"
    echo " INetSim Control"
    echo "============================================================"
}

#########################################
# 启动
#########################################

start_inetsim() {

    show_header

    if is_running; then
        echo -e "${YELLOW}[WARN] INetSim 已经运行${NC}"
        status_inetsim
        return 0
    fi

    if [[ -f "${PID_FILE}" ]]; then
        echo -e "${YELLOW}[WARN] 清理残留 PID 文件${NC}"
        rm -f "${PID_FILE}"
    fi

    echo -e "${BLUE}[INFO] 启动 INetSim${NC}"
    echo -e "${BLUE}[INFO] Bind Address : ${BIND_ADDRESS}${NC}"
    echo -e "${BLUE}[INFO] Console Log  : ${CONSOLE_LOG}${NC}"

    nohup "${INETSIM_BIN}" \
        --config="${CONFIG_FILE}" \
        --bind-address="${BIND_ADDRESS}" \
        > "${CONSOLE_LOG}" 2>&1 &

    sleep 3

    if is_running; then

        echo -e "${GREEN}[OK] INetSim 启动成功${NC}"

        local pid
        pid=$(cat "${PID_FILE}" 2>/dev/null || echo "Unknown")

        echo
        echo "PID : ${pid}"
        echo

        return 0
    fi

    echo -e "${RED}[ERROR] INetSim 启动失败${NC}"

    echo
    echo "最近日志："
    echo

    tail -30 "${CONSOLE_LOG}" || true

    exit 1
}

#########################################
# 停止
#########################################

stop_inetsim() {

    show_header

    if ! is_running; then

        echo -e "${YELLOW}[WARN] INetSim 未运行${NC}"

        rm -f "${PID_FILE}" 2>/dev/null || true

        return 0
    fi

    echo -e "${BLUE}[INFO] 停止 INetSim${NC}"

    if [[ -f "${PID_FILE}" ]]; then

        local pid
        pid=$(cat "${PID_FILE}")

        kill "${pid}" 2>/dev/null || true

        sleep 3
    fi

    pkill -f inetsim 2>/dev/null || true

    rm -f "${PID_FILE}" 2>/dev/null || true

    echo -e "${GREEN}[OK] INetSim 已停止${NC}"
}

#########################################
# 状态
#########################################

status_inetsim() {

    show_header

    if is_running; then

        echo -e "${GREEN}[RUNNING] INetSim 正在运行${NC}"

        echo

        ps aux | grep '[i]netsim'

        echo

        if [[ -f "${PID_FILE}" ]]; then

            echo "PID File : ${PID_FILE}"
            echo "PID      : $(cat "${PID_FILE}")"
        fi

    else

        echo -e "${RED}[STOPPED] INetSim 未运行${NC}"
    fi
}

#########################################
# 查看日志
#########################################

show_logs() {

    case "${1:-service}" in

        main)

            sudo tail -f "${LOG_DIR}/main.log"
            ;;

        service)

            sudo tail -f "${LOG_DIR}/service.log"
            ;;

        console)

            tail -f "${CONSOLE_LOG}"
            ;;

        *)

            echo "支持:"
            echo "  logs main"
            echo "  logs service"
            echo "  logs console"
            ;;
    esac
}

#########################################
# 查看端口
#########################################

show_ports() {

    show_header

    sudo ss -lntup | grep inetsim || true
}

#########################################
# 重启
#########################################

restart_inetsim() {

    stop_inetsim

    sleep 2

    start_inetsim
}

#########################################
# 帮助
#########################################

usage() {

cat << 'EOF'

============================================================
 INetSim Control Script
============================================================

用途:
  管理 INetSim 恶意软件动态分析模拟环境

功能:
  - 启动 INetSim
  - 停止 INetSim
  - 重启 INetSim
  - 查看运行状态
  - 查看模拟服务日志
  - 查看启动日志
  - 查看后台控制台日志
  - 查看监听端口

------------------------------------------------------------
基本命令
------------------------------------------------------------

启动服务

  sudo ./inetsimctl.sh start

停止服务

  sudo ./inetsimctl.sh stop

重启服务

  sudo ./inetsimctl.sh restart

查看运行状态

  sudo ./inetsimctl.sh status

查看监听端口

  sudo ./inetsimctl.sh ports

------------------------------------------------------------
日志查看
------------------------------------------------------------

查看服务通信日志

  sudo ./inetsimctl.sh logs service

对应文件:

  /var/log/inetsim/service.log

主要记录:

  DNS请求
  HTTP请求
  HTTPS请求
  SMTP请求
  FTP请求
  IRC请求
  NTP请求

------------------------------------------------------------

查看主日志

  sudo ./inetsimctl.sh logs main

对应文件:

  /var/log/inetsim/main.log

主要记录:

  服务启动
  服务停止
  配置加载
  子进程创建
  错误信息

------------------------------------------------------------

查看控制台日志

  sudo ./inetsimctl.sh logs console

对应文件:

  ./console.log

主要记录:

  Simulation running
  Forking services
  服务初始化过程
  运行期间输出

------------------------------------------------------------
动态分析实验室使用流程
------------------------------------------------------------

1. 启动 INetSim

   sudo ./inetsimctl.sh start

2. 查看运行状态

   sudo ./inetsimctl.sh status

3. Windows样本机配置DNS

   DNS:
   101.101.101.129

4. 验证DNS接管

   nslookup baidu.com

5. 查看恶意软件联网行为

   sudo ./inetsimctl.sh logs service

------------------------------------------------------------
实验室推荐网络结构
------------------------------------------------------------

        ┌─────────────────┐
        │ Windows 样本机  │
        │ 101.101.101.x   │
        └────────┬────────┘
                 │
                 │ DNS
                 ▼
        ┌─────────────────┐
        │ REMnux          │
        │ INetSim         │
        │ 101.101.101.129 │
        └─────────────────┘

------------------------------------------------------------
常见故障
------------------------------------------------------------

问题:
  PIDfile exists

原因:
  上次异常退出

处理:

  sudo ./inetsimctl.sh stop

或

  sudo rm -f /var/run/inetsim.pid

------------------------------------------------------------

问题:
  Address already in use

原因:
  53/80/443端口已被占用

排查:

  sudo ss -lntup

------------------------------------------------------------

问题:
  service.log无内容

原因:
  尚无客户端连接

验证:

  curl http://101.101.101.129

------------------------------------------------------------

问题:
  Windows无法访问模拟互联网

检查:

  DNS是否配置为INetSim地址

  nslookup qq.com

是否返回:

  101.101.101.129

------------------------------------------------------------

日志目录

  /var/log/inetsim/

配置文件

  /etc/inetsim/inetsim.conf

PID文件

  /var/run/inetsim.pid

控制台日志

  ./console.log

============================================================

EOF

}

#########################################
# 主逻辑
#########################################

case "${1:-}" in

    start)
        start_inetsim
        ;;

    stop)
        stop_inetsim
        ;;

    restart)
        restart_inetsim
        ;;

    status)
        status_inetsim
        ;;

    logs)
        show_logs "${2:-service}"
        ;;

    ports)
        show_ports
        ;;

    *)
        usage
        ;;
esac