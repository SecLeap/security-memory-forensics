# tcpdump 安装实战手册

## 获取与安装

在隔离 Ubuntu 从可信仓库安装：

```bash
sudo apt update
sudo apt install tcpdump
```

记录软件包版本、实验网卡名、抓包过滤条件和输出路径。

## 验证与最小使用

只在内部实验接口抓包。对无害 DNS/HTTP 请求保存 PCAP，记录开始/停止时间和文件 SHA-256；不在宿主、办公网或可出网接口抓包。

## 联动与回滚

将 PCAP 的 DNS、五元组和会话时间与 FakeDNS/Apache/INetSim 日志、Win11 Wireshark 和内存 socket 交叉验证。完成后停止捕获，归档 PCAP 并还原快照。

## 使用方法

1. 用 `ip link` 确认实验接口，再设置仅针对实验网段/协议的捕获过滤条件。
2. 启动测试前开始写入案例 PCAP，停止后记录文件大小、SHA-256、接口和过滤器。
3. 用 Wireshark 复核 DNS/HTTP/会话时间，不在 Ubuntu 上保存无关接口流量。

## 实战场景与完成标准

场景：作为 Win11 Wireshark 的服务端视角复核。完成标准是两端 PCAP 的时间和五元组一致，并能与服务日志和内存网络对象交叉解释。
