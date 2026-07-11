# FakeNet-NG 实战手册

FakeNet-NG 是 Mandiant FLARE 的动态网络分析工具。它可在隔离的 Windows 分析机上拦截/重定向流量并模拟网络服务，同时生成网络 PCAP 和 HTML 网络行为报告。它会改变本机网络处理方式，因此只能在快照化、断网、无 NAT/桥接的实验虚拟机中运行，绝不能在宿主机、生产终端或办公网络中运行。

官方项目：[mandiant/flare-fakenet-ng](https://github.com/mandiant/flare-fakenet-ng)。本手册以官方文档中的 Windows 独立可执行文件模式为默认方案。

## 获取与安装

1. 仅从 [官方 Releases](https://github.com/mandiant/flare-fakenet-ng/releases) 获取 Windows 独立发布包；记录 release 标签、下载 URL、SHA-256、许可证和获取时间。
2. 解压到隔离 Win11 虚拟机的 `C:\Lab\Tools\FakeNet-NG`；不要从第三方“免安装包”、网盘或整合镜像获取。
3. 官方说明该工具可能因流量拦截、服务模拟和 PyInstaller 打包而被 AV/EDR 误报。仅在已验证官方哈希、隔离 VM 和明确授权条件下处理该提示；不要在生产设备添加通用排除规则。
4. 以管理员 PowerShell 验证文件和帮助信息：

```powershell
cd C:\Lab\Tools\FakeNet-NG
Get-FileHash .\fakenet.exe -Algorithm SHA256
.\fakenet.exe --help
```

5. 验证完成后创建 `win11-fakenet-clean` 快照，并记录 Win11 版本、FakeNet-NG 版本、网卡名称、IP 与默认路由状态。

## 工作模式选择

| 模式 | 启动服务 | 适用场景 | 不能同时做的事 |
| --- | --- | --- | --- |
| 本地模拟 | Win11 上 FakeNet-NG | 快速观察单机的 DNS/HTTP/其他协议访问尝试 | 不同时使用 Debian 的 FakeDNS、Apache 或 INetSim 解释同一端口/会话 |
| 外部模拟 | Debian FakeDNS + Apache 或 INetSim | 需要独立服务端日志、可控响应或跨主机 PCAP | 不启动 FakeNet-NG 的流量拦截/服务模拟 |
| 对照实验 | 同一无害测试程序分别运行两次 | 比较本地拦截与外部服务视角 | 不在同一次运行中混用两种网络模拟模式 |

FakeNet-NG 生成的“原始目的地址”与“重定向后本地 listener”需在报告中分别说明；不要把本地重定向地址误写成真实远端基础设施。

## 配置原则

FakeNet-NG 默认使用 `configs\default.ini`，可用 `-c` 指定案例配置。每次实验都复制默认配置到案例目录，不直接修改工具目录中的唯一默认文件。

```text
C:\Lab\Evidence\LAB-002\
  01-配置\LAB-002-fakenet.ini
  02-FakeNet-原始输出\
  03-Noriben-原始输出\
  04-PCAP与服务日志\
  05-内存镜像与Volatility\
```

配置审阅重点：

- **Diverter**：是否拦截流量、是否保存 PCAP、重定向范围与默认 listener。
- **Listeners**：本次实验实际需要的 DNS、HTTP、HTTPS、SMTP 或原始 TCP/UDP listener；关闭无关服务以降低噪声。
- **日志与响应内容**：使用无害、固定、带版本号的响应；配置副本与响应文件均计算 SHA-256。
- **网络模式**：实验机保持无 NAT、无桥接、无共享网络；FakeNet-NG 不是“允许联网”的替代品。

先用无害测试客户端验证配置，再处理授权样本。修改配置后必须另存为新版本，并记录变更原因、时间与影响端口。

## 使用方法

### 1. 启动前准备

1. 还原 Win11 快照，确认没有 NAT/桥接、默认出网路由或宿主共享功能。
2. 关闭 Debian 模拟服务，或选择外部模拟模式而不启动 FakeNet-NG。
3. 启动 Wireshark（仅实验网卡）和 Noriben；记录其开始时间与输出目录。
4. 为 FakeNet-NG 创建案例配置和输出目录，记录各文件哈希。

### 2. 启动与记录

以管理员权限启动，优先在控制台保留实时日志：

```powershell
cd C:\Lab\Tools\FakeNet-NG
.\fakenet.exe -c C:\Lab\Evidence\LAB-002\01-配置\LAB-002-fakenet.ini -l C:\Lab\Evidence\LAB-002\02-FakeNet-原始输出\fakenet.log
```

可先运行 `fakenet.exe --help` 核对当前版本参数。`-v` 用于增加控制台详细日志；`-p`/`--no-pause` 仅用于已验证的自动化流程。运行时观察以下字段：时间、Diverter/Listener 名称、原始源/目的地址、重定向后地址、端口、PID、进程名、协议、URI/命令等网络行为指标。

### 3. 触发与停止

1. 启动无害测试程序或明确授权材料，立即记录 PID、命令行和操作时间。
2. 只观察本次实验所需时间窗；如发现预期外行为，停止测试程序并保留当前证据。
3. 使用 `Ctrl+C` 正常结束 FakeNet-NG，等待其写完 PCAP 和 HTML report 后再关闭控制台。
4. 归档控制台日志、FakeNet PCAP、HTML report、案例 INI、Wireshark PCAP、Noriben PML/CSV/报告和内存镜像；分别计算 SHA-256。
5. 关闭虚拟机并还原快照，检查网络设置是否恢复正常。

## 报告判读与证据关联

FakeNet-NG 的 HTML report 会按进程及应用/传输层协议组织网络行为指标；PCAP 则保留较低层的会话证据。推荐的结论链：

| 观察对象 | FakeNet-NG 证据 | 独立复核 | 内存侧复核 |
| --- | --- | --- | --- |
| 进程归属 | PID、进程名、Diverter 日志 | Noriben/Procmon、System Informer | `windows.pslist`、`windows.cmdline` |
| DNS 请求 | DNS listener 记录、PCAP | Wireshark DNS 包 | `windows.netscan` 与进程对象；注明缓存/关闭状态 |
| HTTP/HTTPS 尝试 | listener 日志、HTML NBI、PCAP | Wireshark/Fiddler（仅授权测试） | socket、VAD/模块与线程上下文 |
| 非标准端口 | Diverter 重定向与 Raw listener 记录 | PCAP 五元组 | 进程 PID 与网络对象 |

单个 NBI、PID 或 PCAP 会话都不能独立证明恶意性。报告必须区分“程序尝试的原始目的地”“FakeNet-NG 重定向后的本地端点”“实际未发生的外网连接”。

## 与 Noriben 和 Volatility 3 的联合场景

**目标**：在不接入互联网的前提下，观察无害测试程序的 DNS/HTTP 尝试并在内存镜像中验证网络对象。

1. 选择“本地模拟”模式：Win11 只保留内部网卡，Debian 的 FakeDNS/Apache/INetSim 全部停止。
2. 启动 Wireshark、Noriben 和 FakeNet-NG；记录三个工具的开始时间。
3. 运行无害测试程序，记录 PID、FakeNet-NG 的 DNS/HTTP NBI 和 Wireshark 会话。
4. 在连接仍活跃的窗口使用已验证工具采集内存，记录采集开始/结束时间与 SHA-256。
5. 使用 Volatility 3 的 `windows.pslist`、`windows.cmdline`、`windows.netscan`，必要时再查看模块/VAD，关联 PID、五元组和时间。
6. 结束并归档全部证据；报告说明哪些连接被本地重定向、哪些网络对象因关闭/回收未在镜像出现。

## 常见问题与排查

| 现象 | 优先检查 | 处理原则 |
| --- | --- | --- |
| 启动失败或监听冲突 | 是否同时运行 FakeDNS、Apache、INetSim、其他代理/抓包工具 | 选择单一网络模拟模式，停止冲突服务后从干净快照重测 |
| 无法拦截流量 | 管理员权限、实验网卡、配置中的 Diverter/Listener、Windows 安全产品提示 | 先用无害 DNS/HTTP 客户端验证；不在宿主机或生产网排错 |
| 没有 PCAP/HTML report | 输出目录权限、磁盘空间、是否正常 `Ctrl+C` 停止 | 等待写入完成，保留控制台日志和配置副本 |
| 目的地址看起来像本机 | 流量是否已被 Diverter 重定向 | 在报告中同时记录原始与重定向后端点 |
| 与 Debian 日志不一致 | 是否误混用了本地/外部模拟模式、时间/时区 | 每次实验只选一个主模拟模式，统一 UTC 时间线 |

## 完成清单

- [ ] 官方 release、哈希、版本、INI、网卡和快照编号已登记。
- [ ] FakeNet-NG、Noriben、Wireshark、内存镜像的开始/结束时间可对齐。
- [ ] PCAP、HTML report、控制台日志和案例配置均已归档并计算 SHA-256。
- [ ] 报告明确区分原始目的地、本地重定向端点与真实网络连通性。
- [ ] FakeNet-NG 已停止，Win11 网络设置和快照已恢复。
