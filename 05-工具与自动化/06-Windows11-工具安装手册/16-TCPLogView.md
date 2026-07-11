# TCPLogView 安装实战手册

## 获取与安装

从 [NirSoft TCPLogView](https://www.nirsoft.net/utils/tcp_log_view.html) 获取便携包，核对哈希后解压至 `C:\Lab\Tools\TCPLogView`。仅使用可信官方下载页的版本。

## 验证与最小使用

对无害 DNS/HTTP 测试记录连接视图，导出 CSV 并保留工具版本、主机时间和网卡信息。它只作辅助，不能替代 PCAP。

## 内存取证联动

用时间、五元组和 PID 将连接视图与 Wireshark、Debian 服务日志及 Volatility socket 结果关联。

## 使用方法

1. 启动前记录网络接口和系统时间；运行时只观察实验会话。
2. 导出连接列表为 CSV，保存本次工具版本、过滤条件和时间。
3. 将连接视图作为快速筛选，回到 PCAP 验证数据包和会话方向。

## 实战场景与完成标准

场景：快速确认测试程序对 Debian 的连接时间窗。完成标准是该时间窗与 Wireshark/服务端日志一致，并在内存分析中说明是否还能看到 socket。
