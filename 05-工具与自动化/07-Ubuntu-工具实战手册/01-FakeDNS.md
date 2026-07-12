# FakeDNS 实战手册

> 适用范围：在隔离 Ubuntu 模拟服务机中，将无害测试域名解析到该实验机的静态地址，并保留可关联的查询记录。FakeDNS 仅服务于内部实验网络，不提供递归解析、转发或互联网出口。

[FakeDNS](https://pypi.org/project/fakedns/) 用于为受控实验提供确定性的 DNS 应答。使用它前，先确认本次实验采用“DNS/HTTP 分离”或“混合模拟”模式；若由 INetSim 提供 DNS，则不启动 FakeDNS。

## 获取与准备

1. 在 Ubuntu 的隔离快照中创建独立 Python 虚拟环境，从官方 PyPI 页面获取包；记录 Ubuntu、Python、包版本、下载来源和虚拟机快照。
2. 将案例规则、启动记录和日志保存到案例专用目录；规则只包含为本次实验创建的无害测试域名与 Ubuntu 实验地址。
3. 启动前记录实验网卡地址，并用 `ss -lntup` 确认 DNS 53 端口未被 INetSim 或其他服务占用。

```bash
python3 -m venv ~/fakedns-venv
~/fakedns-venv/bin/pip install fakedns
~/fakedns-venv/bin/python -m pip show fakedns
ss -lntup
```

不同包版本的命令行参数和规则格式可能不同。以该版本的项目说明和 `--help` 输出为准，并将实际启动命令、规则副本及其 SHA-256 写入实验记录。

## 证据准备

```text
<案例编号>/ubuntu/fakedns/
├─ rules/              # 规则副本；仅限无害测试域名
├─ logs/               # 查询或服务管理器日志
├─ commands.txt        # 实际命令、绑定地址、启动/停止 UTC
└─ manifest.sha256     # 规则与日志哈希清单
```

记录域名、查询类型、客户端 IP、响应地址、时间、工具版本和规则哈希。不要在规则中加入真实内部域名、生产 DNS 地址或 DNS 转发配置。

## 使用方法

### 1. 配置并启动受控解析

1. 为案例复制一份规则，令测试域名只解析到 Ubuntu 实验 IP；不要修改唯一的全局规则。
2. 按已核验版本的官方说明启动服务，并只绑定 Ubuntu 的实验网卡地址；保存终端输出或服务日志。
3. 再次使用 `ss -lntup` 记录监听地址与端口，确认没有在宿主、办公网或所有网卡上意外监听。

### 2. 从 Win11 验证

1. 在 Win11 分析机仅对无害测试域名执行 `nslookup` 或 `Resolve-DnsName`，保存请求时间与响应地址。
2. 在 Ubuntu 侧保留查询日志，并以 `tcpdump` 或 Wireshark 在实验接口验证 DNS 请求与响应。
3. 仅在确认域名、源 IP、响应地址与时间一致后，继续进行固定 HTTP 页面等后续无害测试。

## 与内存取证联动

将 DNS 查询时间、客户端 IP、域名和响应地址与 Windows 的进程 PID、Procmon/Wireshark 记录及内存镜像中的网络对象交叉比对。DNS 日志只能证明 Ubuntu 收到查询，不能单独证明由某个 Windows 进程发起；进程归属应由 PCAP、实时观察或镜像证据支持。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| 53 端口无法绑定 | 停止或改绑 INetSim DNS；重新记录端口监听清单。 |
| Win11 未收到预期应答 | 检查两台虚拟机 IP、Win11 DNS 设置、规则中的测试域名和实验网卡绑定。 |
| 日志与 PCAP 时间不一致 | 先核对两台虚拟机 UTC/时区和抓包起止时间，再解释延迟。 |

- [ ] 已记录工具/Python 版本、来源、规则哈希、绑定地址和快照编号。
- [ ] 仅监听内部实验网卡，且未启用递归、转发或外网解析。
- [ ] DNS 日志、Ubuntu PCAP 与 Win11 侧观察已按时间关联。
- [ ] 实验结束后已停止服务并还原快照。

## 官方资料

- [FakeDNS PyPI 项目页](https://pypi.org/project/fakedns/)
- [Ubuntu 工具实战手册导航](README.md)
