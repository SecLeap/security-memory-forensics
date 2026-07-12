# Cheat Engine 7.7 实战手册

> 适用范围：隔离 Win11 实验 VM 中，对良性测试程序、公开教学样本或明确授权的动态分析对象进行**只读内存定位**。Cheat Engine 不解析离线 RAM 镜像；它的实时观察结果必须通过关键时点采集的全量镜像，再由 Volatility 3/MemProcFS 验证。

Cheat Engine 7.7 提供进程内存查看和搜索能力，但也包含写入、代码注入、调试、表脚本和远程功能。本仓库仅允许其查看进程内存区域、搜索已知字节/字符串、记录地址与截图；禁止编辑值、冻结值、写入内存、加载 Cheat Table、注入代码、使用 DBVM、CEServer 或远程扫描。

## 获取、校验与实验部署

1. 从 [Cheat Engine 官方下载页](https://cheatengine.org/downloads.php) 获取 Windows 7.7；官方将其定位为教育/私人用途，并要求遵守目标软件许可条款。
2. 保存安装包至 `C:\Lab\Installers\CheatEngine\`，记录 URL、版本、文件名、SHA-256、签名状态和许可信息；仅在隔离实验 VM 安装。
3. 安装器可能出现额外推荐项或安全软件告警。不要为安装而关闭安全防护、添加永久排除或从第三方“便携版”下载；无法按组织策略验证时，不安装。

```powershell
Get-FileHash 'C:\Lab\Installers\CheatEngine\CheatEngine77.exe' -Algorithm SHA256
Get-AuthenticodeSignature 'C:\Program Files\Cheat Engine 7.7\cheatengine-x86_64.exe' |
  Format-List Status,StatusMessage,SignerCertificate
```

实际安装路径/文件名可能不同，以本机验证结果为准。安装完成后创建 VM 快照，并以良性测试进程验证“选择进程—仅查看内存—退出”流程。

## 使用边界与证据记录

每次会话记录工具版本与哈希、VM 快照、目标 PID/路径/命令行、目标 SHA-256、开始/结束 UTC、搜索模式、地址、字节长度、截图和后续镜像 SHA-256。

禁止使用或启用以下功能：

- Value 修改、冻结、写入、替换、内存分配或汇编注入；
- Cheat Table（`.CT`）、Lua 脚本、Trainer、Speedhack、DBVM、CEServer、远程扫描；
- 调试控制、断点或对非授权目标附加；
- 针对生产程序、游戏服务、真实用户会话或联网目标的任何操作。

## 只读定位流程

### 1. 进程选择与区域记录

1. 在已启动的受控测试程序中，通过 Cheat Engine 的进程选择界面按 PID 和映像路径确认目标；不要只按进程名选择。
2. 打开 Memory View，仅查看 Memory Regions / 内存映射信息；记录区域起止地址、保护属性、类型、模块归属（如可见）和时间。
3. 不改变任何值或保护属性。发现私有可执行区域、字符串或模块外地址时，先截图与记录，再按 WinPmem 流程采集全量 RAM。

### 2. 搜索已知字节或字符串

搜索输入应来自静态或镜像分析的既有线索，例如 FLOSS 提取的字符串、PEStudio/DiE 的文件头、Ghidra 中的常量；不进行通过反复值变化推断业务状态的扫描。

1. 在 Memory View 中选择只读搜索，指定 ASCII、Unicode 或十六进制字节模式。
2. 保存命中地址、搜索模式、编码、命中前后有限字节、目标 PID 和时间。
3. 将地址写成“运行时 VA”；若需与静态文件对应，另记录模块基址和换算后的 RVA。
4. 对每个关键命中建立截图和文本记录；不要通过编辑或断点验证其功能。

示例记录：`LAB-001 | PID 1234 | VA 0x00007FF6... | UTF-16 字符串 | 命中时间 UTC | 模块基址/RVA | 仅实时观察`。

## 与内存取证的联合使用

1. Cheat Engine 记录 PID、VA、区域属性和观察时间。
2. 立即按 [WinPmem 实战手册](14-WinPmem.md) 采集全量 RAM 镜像，计算 SHA-256。
3. 在 [Volatility 3 实战手册](../02-Volatility3-实战手册.md) 中以同一 PID 检查 VAD、模块、线程和字符串/导出物；用 MemProcFS 复核进程内存映射。
4. 对齐时使用 `RVA = VA - 模块基址`，先排查 ASLR、重定位、线程/进程重启和采集时间差。
5. 报告必须区分“Cheat Engine 实时定位”与“镜像中独立解析器确认的对象”。若镜像无法复现，保留差异，不以实时界面作最终结论。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 无法附加或可见性不足 | 仅在隔离 VM 核对管理员权限、架构和目标授权；不关闭安全控制或使用内核/远程功能绕过 |
| 地址在后续镜像中不同 | 核对 PID、模块基址、ASLR、采集时间与进程重启；保留两侧记录 |
| 安装包被安全软件告警 | 重新核验官方来源和哈希；不能满足策略时停用该工具，不添加永久排除项 |
| 发现可编辑/脚本功能 | 不使用；本手册只允许查看、搜索、截图、记录和镜像互证 |

## 实战检查清单

- [ ] 已记录 Cheat Engine 7.7 来源、哈希、安装状态与 VM 快照。
- [ ] 目标为隔离实验中的授权进程，PID 和映像路径均已确认。
- [ ] 仅执行内存区域查看与已知字节/字符串的只读搜索。
- [ ] 未使用 Cheat Table、脚本、写入、冻结、注入、远程或内核功能。
- [ ] 关键地址已通过 WinPmem 镜像与 Volatility 3/MemProcFS 交叉验证。

## 官方资料

- [Cheat Engine 7.7 官方下载页](https://cheatengine.org/downloads.php)
- [Cheat Engine 官方网站](https://cheatengine.org/)
