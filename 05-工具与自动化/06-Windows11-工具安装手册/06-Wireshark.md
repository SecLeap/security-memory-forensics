# Wireshark 实战手册

> 适用范围：隔离实验网络中，对已授权测试的包捕获和离线 PCAPNG 分析。Wireshark 是协议与包证据工具；它不能仅凭地址或内容将流量可靠归因到 Windows PID，需与 Procmon、服务端日志和内存对象交叉验证。

## 获取与安装

从 [Wireshark 官方下载页](https://www.wireshark.org/download.html) 获取安装包，必要时仅在隔离 VM 安装 Npcap。记录版本、安装包/主程序哈希、Npcap 版本、签名、所选虚拟网卡、MAC/IP、VM 网络拓扑和 UTC 偏移。不要选择宿主、VPN、办公网或未知无线网卡。

## 采集准备

    C:\Lab\Cases\LAB-001\01-动态原始记录\Network\
    ├─ LAB-001.pcapng
    ├─ LAB-001-捕获参数.md
    ├─ LAB-001-显示过滤器.txt
    └─ LAB-001-会话导出.csv

捕获过滤器决定哪些包被写入，显示过滤器只改变已捕获文件的显示，两者语法和证据影响不同。默认优先完整捕获实验网卡的短时间窗，再用显示过滤器分析；高流量场景若必须捕获过滤，记录完整表达式与漏捕风险。

## 使用方法

### 1. 受控抓包

1. 在 Capture Options 确认仅选实验网卡、目标路径和写入格式 PCAPNG；记录开始 UTC、接口和捕获过滤器。
2. 启动测试前开始捕获，关键行为/内存采集完成后立即停止；计算 PCAPNG SHA-256，禁止覆盖原件。
3. 保存 Capture File Properties、接口信息、捕获过滤器和时间窗。文件未关闭前不得计算最终哈希或交给其他工具。

### 2. 离线分析与导出

| 目的 | 显示过滤器示例 | 必须留档 |
| --- | --- | --- |
| DNS 观察 | dns | 查询/应答、事务字段、时间、端点 |
| HTTP 请求 | http.request | URI、Host、方法、时间、TCP 流编号 |
| 指定端点 | ip.addr == 192.0.2.10 | 完整过滤器、包号、方向、端口 |
| 指定会话 | tcp.stream eq 3 | 流编号、五元组、开始/结束、关键包号 |
| TLS 元数据 | tls | SNI 等可见字段、包号；不绕过加密 |

显示过滤不会删除 PCAP 中的包，但导出的子集是派生物。对每次导出保存过滤器、列、包号范围、原 PCAP 哈希、导出文件哈希和 Wireshark 版本。Follow Stream 仅用于阅读已获授权的实验流量；不得解密、导出或外传生产敏感数据。

### 3. 时间线和 PID 复核

先从 PCAP 记录 UTC 时间、五元组、DNS/HTTP/TLS 线索和包/流编号；再用 Procmon 网络事件、FakeNet-NG/Apache 日志和进程创建时间寻找 PID。PCAP 没有原生 Windows PID，不可用“同一 IP”直接归因。

## 与内存取证联动

在内存采集窗口附近，对可疑五元组/端点回查 Volatility netscan 等适用输出、进程 PID、命令行、模块和时间。连接可能在采集前已关闭或因 NAT/代理/DNS 缓存不同而不匹配；报告区分包层事实、日志归因和快照内存对象。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| 没有包 | 核对实验网卡、VM 交换网络、抓包开始时间和过滤器 |
| 看不到 HTTP 内容 | 可能为 TLS 或协议解析差异；记录可见元数据，不尝试绕过加密 |
| 时间不一致 | 检查系统时钟、时区、服务端日志和采集开始/结束时间 |

- [ ] 已保留原始 PCAPNG、接口/过滤器/时间窗、SHA-256 和导出派生物链。
- [ ] 已区分 capture filter 与 display filter，保存完整表达式。
- [ ] 关键会话均有包号/流号、五元组和独立 PID/服务端/内存复核。
- [ ] 未抓取非实验网络，未外传或解密未授权流量。

## 官方资料

- [Wireshark User’s Guide](https://www.wireshark.org/docs/wsug_html/)
- [Wireshark 显示过滤器参考](https://www.wireshark.org/docs/man-pages/wireshark-filter.html)
