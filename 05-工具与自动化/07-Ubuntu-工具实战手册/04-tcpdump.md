# tcpdump 实战手册

> 适用范围：在隔离 Ubuntu 模拟服务机的内部实验接口上捕获 DNS、HTTP 或选定模拟协议流量，为 Win11 侧观察和内存镜像分析提供服务端视角。不得在宿主、办公网、生产网或可出网接口抓包。

[tcpdump](https://www.tcpdump.org/manpages/tcpdump.1.html) 用于保存原始 PCAP。抓包前先最小化范围并明确接口、时区、起止时间和过滤器；PCAP 可能含敏感数据，只保存至受控案例目录，且不提交到本 Git 仓库。

## 获取与准备

1. 在隔离 Ubuntu 的可信软件源中准备 tcpdump，记录软件包版本、实验网卡名、虚拟机快照和调用权限。
2. 用 `ip link`、`ip addr` 确认内部实验接口；接口名不能仅凭旧案例复用。
3. 为案例创建受控 PCAP 目录，预先记录捕获过滤器与计划起止 UTC。

```bash
sudo apt update
sudo apt install tcpdump
tcpdump --version
ip link
ip addr
```

## 证据准备

```text
<案例编号>/ubuntu/pcap/
├─ capture.pcap         # 原始抓包文件；受控存放，不提交 Git
├─ capture.txt          # 接口、过滤器、权限、起止 UTC、文件大小
├─ sha256.txt           # PCAP SHA-256
└─ review-notes.md      # 与服务日志、Win11 PCAP、镜像对象的关联记录
```

用案例编号命名 PCAP，避免覆盖；记录抓包工具版本和完整过滤器。仅在确有授权且实验场景需要时保留载荷，优先采用限制协议和主机范围的捕获过滤器。

## 使用方法

### 1. 确定最小捕获范围

1. 先确认 `ip addr` 显示的实验接口和两台虚拟机的内部地址；不要选择默认路由、宿主共享或办公网络接口。
2. 按本次实验限定协议和端口，例如仅保留 DNS 与 HTTP/HTTPS 的控制流量。
3. 启动测试前开始抓包，测试结束后立即停止；将实际起止时间写入 `capture.txt`。

```bash
sudo tcpdump -i <实验接口> -nn -s 0 -U \
  -w <受控案例目录>/capture.pcap \
  'udp port 53 or tcp port 80 or tcp port 443'
```

上例仅适用于内部实验接口与已授权的 DNS/HTTP 场景。若实验使用其他模拟协议，应采用更窄的、经记录的过滤器；不要执行无过滤的全接口长期抓包。

### 2. 停止、核验和归档

1. 停止捕获后记录文件大小和 SHA-256；保存命令、接口、过滤器、权限与起止 UTC。
2. 用 Wireshark 或 tcpdump 的离线读取功能核对 DNS 请求/响应、HTTP 会话或所选协议的时间与五元组。
3. 将 PCAP 复制到受控证据位置，保留原件只读副本；分析副本与原件都应有哈希。

```bash
sha256sum <受控案例目录>/capture.pcap
tcpdump -nn -r <受控案例目录>/capture.pcap
```

## 与内存取证联动

服务端 PCAP 可用于验证服务是否收到会话、请求的时间和五元组。把这些字段与 FakeDNS/Apache/INetSim 日志、Win11 PCAP、进程 PID/创建时间和镜像网络对象对齐；由于连接可在内存采集前关闭，PCAP 与镜像不一致时必须记录采集时点，而不是直接否定任一证据。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| 没有抓到流量 | 核对实验接口、IP、过滤器、抓包开始时间和服务监听端口。 |
| 抓到无关流量 | 立即停止，缩小过滤器；核验虚拟网络隔离和接口选择。 |
| PCAP 无法读取或哈希不一致 | 保留原文件，记录错误；不要覆盖，重新复制并核验分析副本。 |

- [ ] 已记录 tcpdump 版本、实验接口、过滤器、权限、起止 UTC 和快照编号。
- [ ] 抓包范围仅覆盖内部实验接口和授权协议，未收集无关网络流量。
- [ ] PCAP 已计算 SHA-256，并与服务端日志、Win11 侧证据和内存对象交叉核验。
- [ ] 原始 PCAP 已归档至受控位置，未提交到 Git 仓库。

## 官方资料

- [tcpdump 手册页](https://www.tcpdump.org/manpages/tcpdump.1.html)
- [Wireshark 文档](https://www.wireshark.org/docs/)
