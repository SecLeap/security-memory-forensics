# Fiddler Classic 实战手册

> 适用范围：隔离 Win11 恶意软件内存分析实验中，对已授权测试程序与自建模拟服务之间的 HTTP(S) 会话进行代理式记录。Fiddler Classic 不解析内存镜像，也不能替代 PCAP、服务端日志或 Volatility 3 网络对象复核。

[Fiddler Classic](https://www.telerik.com/download/fiddler) 是仅适用于 Windows 的 Web 调试代理。官方页面说明它已不再积极开发、没有未来补丁或技术支持承诺；本仓库仅将其用于受控实验的可读 HTTP(S) 会话留档。企业或长期部署应先评估官方推荐的替代产品与组织许可/风险要求。

## 获取与安装

### 1. 获取、校验与版本冻结

1. 仅从 [Telerik 官方下载页](https://www.telerik.com/download/fiddler) 获取 Fiddler Classic；完成页面要求的许可/使用选择后保存下载 URL、版本、文件名和 EULA 信息。
2. 将安装包存至 `C:\Lab\Installers\Fiddler\`，仅安装在隔离 Win11 实验 VM；记录 SHA-256、签名状态、操作者和 VM 快照。
3. 案例期间禁止自动更新或更换版本；Fiddler 版本、系统代理状态、HTTPS 解密状态均影响可见流量。

```powershell
Get-FileHash 'C:\Lab\Installers\Fiddler\<安装包>' -Algorithm SHA256
Get-AuthenticodeSignature 'C:\Program Files (x86)\Fiddler2\Fiddler.exe' |
  Format-List Status,StatusMessage,SignerCertificate
```

路径因安装选项而异；先确认实际 `Fiddler.exe` 路径再校验。不得从非官方站点下载“绿色版”或使用未知 FiddlerScript/扩展。

### 2. 最小验证与恢复点

1. 在未运行测试程序时启动 Fiddler Classic，记录版本与系统代理初始状态。
2. 访问实验室内的良性 HTTP 服务，确认 Session List 出现会话；不能看到会话时，先检查客户端代理设置、Fiddler 过滤器和绑定接口。
3. 保存一次空白/良性测试的 `.saz` 作为工具基线，然后关闭 Fiddler，确认系统代理恢复到实验前状态。
4. 不启用远程客户端代理、上游代理链或 VPN/Dialup 监控；本手册只捕获本机隔离 VM 的受控流量。

## 证据准备与安全边界

```text
C:\Lab\Cases\LAB-001\04-网络记录\Fiddler\
├─ 00-配置记录\
├─ 01-原始会话\
├─ 02-筛选视图\
└─ 03-关联笔记\
```

开始前记录：案例号、Fiddler 版本/哈希、启动/停止 UTC、系统代理设置、实验网卡、测试程序 PID、模拟服务 IP/域名、是否启用 HTTPS 解密、根证书指纹（如启用）及服务端日志路径。

Fiddler 会看到请求 URL、头、Cookie、正文和响应内容。仅捕获自建服务、良性测试程序或明确授权材料；不得输入真实账号、令牌、生产域名或个人数据。保存前检查 `.saz` 是否含敏感字段，遵循案例脱敏/访问控制规则；不要为方便共享而上传会话档。

## 使用方法

### 1. HTTP 会话采集

1. 启动 Fiddler Classic 后先关闭不相关应用，清除历史会话或创建新案例窗口，避免将基线浏览噪声混入证据。
2. 在 Filters 中仅保留实验服务域名/IP、端口或测试窗口时间段；记录过滤条件本身，原始未筛选会话也应保存。
3. 启动测试程序，记录启动时间、PID 和相关 Procmon/Noriben 事件。
4. 结束测试后立即停止捕获，通过 `File > Save > All Sessions` 保存原始 `.saz` 至 `01-原始会话\`；命名示例：`LAB-001_20260711T031500Z_fiddler.saz`。
5. 计算 `.saz` 哈希；筛选、标注或另存的副本写入 `02-筛选视图\`，不能覆盖原始会话。

```powershell
$saz = 'C:\Lab\Cases\LAB-001\04-网络记录\Fiddler\01-原始会话\LAB-001_20260711T031500Z_fiddler.saz'
Get-FileHash $saz -Algorithm SHA256 |
  Tee-Object -FilePath "$saz.sha256.txt"
```

Inspectors 中可查看请求方法、URL、头、Cookie、正文、响应头、状态码、响应正文与时间线。每个结论至少记录会话编号、时间、方法、主机、路径、状态码、关键字段位置和 `.saz` 哈希；不要只保存截图或可复制文本。

### 2. HTTPS 解密：仅限自建实验服务

Fiddler 的 HTTPS 解密依赖本机受信任根证书并会解密经过代理的 TLS 流量。仅当目标为自建服务、测试证书和授权材料时，在 `Tools > Options > HTTPS` 中临时启用解密；严禁对生产、第三方或真实凭据流量解密。

操作顺序：

1. 截图保存启用前的 HTTPS 配置与系统证书存储状态。
2. 启用解密，记录启用时间、Fiddler 版本和根证书主题/指纹。
3. 只运行一次受控测试，保存 `.saz` 与服务端日志。
4. 停止捕获后关闭 HTTPS 解密，按 Fiddler 界面提供的清理方式移除其根证书；记录清理时间和清理结果，再创建实验 VM 快照。

HTTPS 解密产生的是代理观察结果。对“某进程发起某请求”的归因，仍须用 PID 时间、PCAP、模拟服务日志和内存网络对象复核。

### 3. 与 Wireshark / FakeNet-NG 的组合

| 工具 | 主要证据 | 与 Fiddler 的关系 |
| --- | --- | --- |
| Fiddler Classic | HTTP(S) 请求/响应、头、正文、会话时间 | 代理层可读会话；保存 `.saz` |
| Wireshark | 接口、五元组、DNS/TLS/原始包时间线 | 验证流量确实经过实验网卡，保留 PCAPNG |
| FakeNet-NG | 本机模拟服务响应与日志 | 可用于受控服务交互；避免与透明重定向/代理设置冲突，先做良性基线验证 |
| Ubuntu 模拟服务 | 服务端访问/应用日志 | 以服务端时间、请求行和源地址复核 Fiddler 会话 |

同一测试只指定一种明确的 HTTP 代理/重定向链。若 Fiddler 与 FakeNet-NG 或其他重定向工具同时启用导致会话缺失、循环或代理冲突，停止测试、记录配置并在快照恢复后按单一链路重测。

## 与内存取证的联合分析

### 场景一：HTTP 会话到进程内存对象

1. Fiddler 保存 `.saz`，记录请求时间、目标、方法、状态码和可疑路径/正文线索。
2. 以 Procmon/Noriben、TaskExplorer 或系统记录将测试 PID 与同一时间窗口关联。
3. 在关键会话后按 [WinPmem 实战手册](14-WinPmem.md) 采集 RAM 镜像并计算 SHA-256。
4. 以 [Volatility 3 实战手册](../02-Volatility3-实战手册.md) 复核进程、命令行、socket、VAD、模块和字符串；将域名、路径或 User-Agent 作为待验证线索，而不是单独证明。
5. 用 Wireshark PCAP 或 Ubuntu/FakeNet 服务端日志复核时间和通信方向。

### 场景二：仅见 CONNECT/TLS、没有可读正文

这通常表示未启用 HTTPS 解密、应用未使用系统代理、协议不在 Fiddler 覆盖范围，或流量被过滤。不得为获得正文而对非授权目标解密；保存现有 `.saz`、PCAP、PID/时间和配置，回到服务端日志、Wireshark 与内存对象交叉分析。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| Session List 没有流量 | 检查客户端是否使用系统代理、过滤器是否过严、服务是否走非 HTTP(S) 协议；用良性本地服务验证 |
| HTTPS 报证书错误 | 仅在自建实验服务中检查临时根证书、系统时间和解密配置；测试后关闭解密并清理证书 |
| Fiddler 与其他工具冲突 | 固定代理/重定向链，只保留一种主链路；记录配置后在快照恢复环境重测 |
| `.saz` 含敏感信息 | 限制访问，保留原始受控副本；建立脱敏派生副本，不覆盖原始档 |
| 系统代理未恢复 | 停止 Fiddler，按记录核对实验 VM 代理设置；不要在生产主机使用本流程 |

## 实战检查清单

- [ ] 已记录 Fiddler Classic 的弃用状态、版本、哈希、代理配置和 VM 快照。
- [ ] 仅捕获隔离实验中的自建/授权 HTTP(S) 流量，未启用远程代理。
- [ ] HTTPS 解密仅用于自建服务，且已记录临时根证书并在测试后清理。
- [ ] 已保存原始 `.saz`、SHA-256、过滤条件、服务端日志和时间基准。
- [ ] 对请求与进程的归因已由 PID、PCAP/服务日志和 Volatility 3 网络对象交叉验证。

## 官方资料

- [Fiddler Classic 官方下载页](https://www.telerik.com/download/fiddler)
- [Fiddler Classic 文档](https://docs.telerik.com/fiddler/)
