# TCPLogView 实战手册

> 适用范围：隔离 Windows 实验机中，对 TCP/IP 连接的快速实时辅助观察与导出。TCPLogView 不是包捕获工具，不能替代 PCAP、服务端日志或内存网络对象，且连接信息不自动提供可靠的进程归因。

[TCPLogView](https://www.nirsoft.net/utils/tcp_log_view.html) 为便携式 NirSoft 工具。仅从官方页面获取，保存 ZIP 与主程序 SHA-256 至 C:\Lab\Installers\TCPLogView\ 和 C:\Lab\Tools\TCPLogView\；记录版本、签名状态、主机时间、时区、实验网卡和 VM 快照。

## 使用前准备

在测试前确认系统时间与 Ubuntu/服务端时间同步或已记录偏差。启动 TCPLogView 后先用自建 DNS/HTTP 测试确认显示的本地/远端地址、端口、状态和时间字段；不要将它作为未知样本执行时的唯一网络记录。

    C:\Lab\Cases\LAB-001\01-动态原始记录\TCPLogView\
    ├─ LAB-001-连接视图.csv
    ├─ LAB-001-截图\
    └─ LAB-001-观察说明.md

## 使用方法

1. 在实验开始前记录版本、网卡、UTC 偏移和观察开始时间；仅关注隔离网段。
2. 按本地/远端地址、端口、协议和状态筛选/排序，保存截图或 CSV。记录各列含义、导出时间、过滤器和 CSV SHA-256。
3. 以 TCPLogView 的连接时间窗生成候选五元组后，回到 Wireshark 原始 PCAPNG 查看包号、方向、握手/关闭与应用层内容；再回查服务端日志。
4. 关联 PID 时，只使用同时段 Procmon 网络事件、System Informer/Process Explorer 实时观察或 Volatility 网络对象等独立证据。

| 观察项 | 可以说明 | 不能说明 |
| --- | --- | --- |
| 本地/远端地址端口 | 某时点可见连接端点 | 应用内容、真实外网通信或 PID |
| 状态变化 | 工具观察到的 TCP 状态 | 完整会话生命周期或失败原因 |
| CSV 行 | 导出时界面中的快照 | 原始包序列或未显示连接 |

## 与内存取证联动

在内存采集前记录连接视图与 UTC；在 Volatility/MemProcFS 中检查适用网络插件的对象、所属 PID、命令行和时间。快照中没有连接可能是关闭、扫描差异或工具可见性限制，不否定 TCPLogView/PCAP 的历史观察。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| 未显示预期连接 | 核对网卡、时间窗、IPv4/IPv6、短连接已关闭和权限；用 PCAP 验证 |
| 与 Wireshark 不一致 | 比较接口、UTC、NAT/代理、连接关闭时间和包号 |
| 想用连接行判定进程 | 停止；必须增加 Procmon/实时进程/内存证据 |

- [ ] 已记录工具版本/哈希、主机时区、网卡和观察时间。
- [ ] CSV/截图均保留输入范围、列、筛选和自身哈希。
- [ ] 每条关键连接均已用 PCAP 和服务端/进程/内存记录复核。
- [ ] 未把连接快照当作完整流量或 PID 归因证据。

## 官方资料

- [TCPLogView 官方页面](https://www.nirsoft.net/utils/tcp_log_view.html)
