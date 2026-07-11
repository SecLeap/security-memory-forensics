# Wireshark 安装实战手册

## 获取与安装

从 [Wireshark 官方下载页](https://www.wireshark.org/download.html) 获取安装程序；仅在隔离 Win11 安装 Npcap（如安装包提示）。记录版本、安装包哈希和捕获网卡名称。

## 验证与最小使用

1. 只选择实验内部网络网卡，不选择宿主、VPN 或办公网络适配器。
2. 用无害 DNS/HTTP 测试生成流量，保存 PCAPNG 与抓取/显示过滤器。
3. 提取时间、五元组、DNS 名称与 HTTP 请求，附回案例时间线。

## 内存取证联动

将五元组和时间与 `windows.netscan`、进程 PID、Debian 服务日志交叉验证；已关闭连接可能不会在镜像中可见。

## 使用方法

1. 开始抓包前确认仅选择实验网卡，并在 capture comment 中记录案例编号。
2. 用 `dns`、`http`、`tcp.stream eq <编号>` 等显示过滤器查看无害测试流量；保存过滤器文本。
3. 对目标会话记录请求时间、源/目的 IP、端口、域名、Host 和流编号，并导出 PCAPNG 副本。

## 实战场景与完成标准

场景：验证 Win11 对 FakeDNS/Apache 的 DNS→HTTP 请求。完成标准是 DNS 应答、HTTP 请求、Debian access log 和发起 PID 能以时间与五元组关联。
