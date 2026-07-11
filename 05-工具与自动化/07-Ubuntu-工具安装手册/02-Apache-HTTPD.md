# Apache HTTPD 安装实战手册

## 获取与安装

仅在隔离 Debian 实验机从可信发行版仓库安装：

```bash
sudo apt update
sudo apt install apache2
```

记录软件包版本、站点配置和测试页面 SHA-256。测试页面必须为固定、无害内容，不放置可执行文件或真实数据。

## 验证与最小使用

将服务绑定到实验网卡；从 Win11 用浏览器或无害测试程序发起 HTTP 请求，保存 access/error log、请求时间、路径、Host 和源 IP。

## 联动与回滚

Apache 独占 80/443；使用它时关闭/改绑 INetSim HTTP 服务。用 PCAP 和服务端日志验证请求，再关联 Win11 Procmon/进程和内存 socket；实验结束后停止服务并还原快照。

## 使用方法

1. 为案例建立独立虚拟主机与固定无害页面，记录配置和页面 SHA-256。
2. 用 `ss -lntup` 确认实验网卡的 HTTP 端口唯一监听者为 Apache。
3. 从 Win11 请求页面，保存 access/error log、PCAP、请求路径和时间。

## 实战场景与完成标准

场景：验证 DNS 应答后的 HTTP 请求。完成标准是 Apache 日志、Wireshark 请求、Win11 PID 和镜像 socket 的关联过程可复核。
