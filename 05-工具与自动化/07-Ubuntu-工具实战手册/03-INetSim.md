# INetSim 实战手册

> 适用范围：在隔离 Ubuntu 模拟服务机中模拟选定的互联网协议服务，并记录无害测试客户端的访问。INetSim 不是代理、网关或互联网出口；不得让其连接生产网络或转发真实流量。

[INetSim](https://www.inetsim.org/) 可为多个协议提供模拟响应与服务日志。它默认可能监听 DNS、HTTP 等端口，因此在启用前必须选择“全服务模拟”或“混合模拟”模式，并处理与 FakeDNS、Apache 的端口冲突。

## 获取与准备

1. 在隔离 Ubuntu 从可信发行版软件源准备 INetSim，记录系统、软件包和配置版本，以及虚拟机快照。
2. 从默认配置复制出一份案例配置；不直接改写唯一的全局配置。为配置、日志、report 与 data 指定案例专用位置。
3. 明确本次需要的模拟服务。混合模式必须关闭或改绑 DNS/HTTP 等将由 FakeDNS/Apache 处理的服务。

```bash
sudo apt update
sudo apt install inetsim
inetsim --version
inetsim --help
ss -lntup
```

配置键和值以安装版本的 `inetsim.conf` 注释、man page 与官方文档为准；将实际配置和启动命令作为证据保留，而不是从其他案例直接套用。

## 证据准备

```text
<案例编号>/ubuntu/inetsim/
├─ config/              # 案例配置副本和 SHA-256
├─ logs/                # session 与服务日志
├─ report/              # INetSim report 原始副本
├─ data/                # 仅限模拟服务生成的数据
├─ commands.txt         # 服务选择、绑定地址和启停 UTC
└─ manifest.sha256      # 配置与输出哈希清单
```

记录启用的服务、监听地址/端口、配置哈希、日志目录、服务启停时间和实验网卡。`data` 目录中的材料可能具有风险或敏感性，不应提交到 Git 仓库。

## 使用方法

### 1. 选择服务模式

| 模式 | 启用服务 | 启动前检查 |
| --- | --- | --- |
| 全服务模拟 | INetSim 提供 DNS、HTTP 和选定的其他服务 | FakeDNS、Apache 已停止，端口由 INetSim 唯一监听。 |
| 混合模拟 | INetSim 仅提供非 DNS/HTTP 的选定服务 | FakeDNS/Apache 端口未被 INetSim 占用；配置副本已记录。 |

启动前使用 `ss -lntup` 保存端口清单；启动后再次保存，以确认实际监听与案例配置一致。

### 2. 用无害客户端验证与记录

1. 先使用无害测试客户端访问一个已启用的模拟服务，确认日志和 report 写入案例目录。
2. 再从 Win11 分析机发起经授权的测试请求；记录时间、源 IP、协议、端口和测试标识。
3. 用 Ubuntu `tcpdump` 或 Win11 Wireshark 保存会话 PCAP，并将其与 INetSim session/report 按时间和五元组比对。

## 与内存取证联动

服务端 report 表示请求到达模拟服务，并不等同于 Windows 内存中仍存在连接。关联时至少比较服务端时间、PCAP 五元组、Win11 进程 PID/创建时间以及镜像中的网络对象；对缺失对象应考虑连接已关闭、采集延迟和 PID 复用。证据归档遵循[证据管理与报告](../../06-证据管理与报告/README.md)的规则。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| 启动时端口冲突 | 检查 FakeDNS、Apache 与 INetSim 的服务选择；保留端口清单后停止或改绑冲突服务。 |
| 未生成 report 或日志 | 检查案例目录权限、配置中的输出位置、服务是否实际启用和测试协议是否匹配。 |
| 收到意外外部流量 | 立即停止服务，核验虚拟交换网络、路由、防火墙和共享设置。 |

- [ ] 已记录版本、案例配置哈希、启用服务、监听端口和快照编号。
- [ ] 已选择全服务或混合模式，DNS/HTTP 端口不存在重复监听。
- [ ] session/report、PCAP 和 Win11 侧记录已按时间、五元组关联。
- [ ] 实验结束后已停止服务、归档输出并还原快照。

## 官方资料

- [INetSim 官方文档](https://www.inetsim.org/documentation.html)
- [INetSim 配置说明](https://www.inetsim.org/documentation.html)
