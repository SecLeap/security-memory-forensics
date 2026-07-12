# API Monitor v2r13 x86/x64 实战手册

> 适用范围：隔离实验 VM 中对授权测试程序进行最小化 API 调用记录，并将记录与内存镜像、Procmon 和网络证据对齐。API Monitor 会对目标进程施加监视/插桩影响；它不是离线内存镜像分析器，结果不能替代未插桩状态的证据。

[API Monitor v2 Alpha-r13](https://www.rohitab.com/apimonitor) 是较早的 Alpha 版本。官方页面列出的支持系统截至 Windows 8，且 x64 版只监视 64 位应用、x86 版只监视 32 位应用（x64 安装包包含两种版本）。因此在 Win11 上只能作为经同版本实验验证的辅助工具；不通过关闭安全控制、兼容性绕过或未知 DLL 来强行运行。

## 获取与安装

1. 从 [Rohitab 官方下载页](https://www.rohitab.com/apimonitor) 获取 `API_Monitor_v2r13_x86_x64`；保存原始包、URL、版本、SHA-256、许可证和下载时间。
2. 在隔离 Win11 实验 VM 安装或使用官方 portable 包；创建快照。x64 目标使用 API Monitor x64，x86 目标使用 API Monitor x86。
3. 对同 Windows 版本/补丁/安全策略的良性程序验证一次“启动监视—捕获有限调用—保存 capture—退出”流程，记录兼容性和资源开销。

```powershell
Get-FileHash 'C:\Lab\Installers\API-Monitor\API_Monitor_v2r13_x86_x64.zip' -Algorithm SHA256
Get-ChildItem 'C:\Lab\Tools\API-Monitor' -Recurse -File | Get-FileHash -Algorithm SHA256
```

## 最小化捕获策略

API Monitor 的定义库覆盖大量 API/COM 接口。不要选择“全部 API”；从明确假设出发，每次仅选择少量类别/函数范围，例如文件、注册表、进程/线程、网络或加密中与当前问题直接相关的调用。

每次会话记录：API Monitor 版本/位数、目标 PID/路径/哈希、选择的 Capture Filter、启动方式、开始/结束 UTC、监视方法（由界面显示）、捕获文件哈希、调用线程 ID、DLL、参数、返回值和错误码（如显示）。

禁止：控制/改变 API 调用、设置动作型断点、编辑内存、加载自定义监视 DLL、附加到生产/非授权进程、通过远程/注入方式绕过系统保护。若工具为监视所需的内部机制导致目标崩溃或行为异常，停止并把会话标为“插桩影响，结果受限”。

## 使用方法

### 1. 启动受控目标并设置过滤器

1. 选择与目标位数匹配的 API Monitor 实例。
2. 在 Capture Filter 中仅选中为当前问题准备的最小 API 集；截图保存过滤器内容和版本。
3. 从 API Monitor 启动工作副本，或仅在实验授权范围内附加到已知 PID；记录启动/附加时间与 PID。
4. 开始捕获后仅运行一次有限、可重复的测试步骤；出现异常或噪声失控即停止，不靠扩大过滤器或补丁强行获得结果。
5. 停止捕获，使用 r13 的 Save Capture 功能保存原始 capture 至案例目录，并另存截图/文本摘要；不得覆盖原始 capture。

```text
C:\Lab\Cases\LAB-001\03-API-Monitor\
├─ 00-过滤器截图\
├─ 01-原始捕获\
├─ 02-筛选视图\
└─ 03-关联笔记\
```

### 2. 结果解读

Summary 视图可显示线程 ID、发起调用的 DLL、API 参数、返回值和错误信息。每条关键记录应保留：调用时间、PID/TID、DLL、API、参数摘要、返回值/错误、capture 文件偏移/行或截图位置，以及关联的 Procmon/PCAP/内存对象。

| API Monitor 观察 | 可以说明 | 不能单独说明 | 必须复核 |
| --- | --- | --- | --- |
| API 调用及返回值 | 插桩会话中该线程到达某 API | 未插桩运行一定执行同样调用 | Procmon/Noriben、线程/模块与实验时间线 |
| 参数中的路径/域名 | 调用参数包含对应文本 | 文件已成功写入或通信已完成 | 返回值、文件/注册表事件、PCAP/服务端日志 |
| 调用 DLL/线程 | 调用归属于当前进程内特定 DLL/线程 | 内存对象在镜像采集时仍存在 | WinPmem 后的 Volatility 3 模块、VAD、线程对象 |

### 3. 与内存取证的联合分析

1. API Monitor 保存最小 capture，记录 PID、TID、DLL、调用/返回时间和关键参数。
2. Procmon/Noriben 记录文件/注册表等实际系统事件，Wireshark/Fiddler/FakeNet 日志记录网络事实。
3. 在关键 API 时间点后以 WinPmem 采集全量 RAM 镜像并计算 SHA-256。
4. Volatility 3 与 MemProcFS 复核相同 PID 的命令行、模块、线程、VAD 和 socket；若静态工具提示相关函数/字符串，再以模块基址与 RVA 对齐。
5. 报告应表述为“API Monitor 插桩会话观察到 X；独立的 Y 证据支持/未支持 X”，不可把单次调用视为完整行为链。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 无法监视目标 | 检查 x86/x64 匹配、管理员权限和 Win11 兼容性验证；不通过关闭安全控制或注入未知组件绕过 |
| 目标崩溃/行为改变 | 停止捕获，保留日志与版本；在干净快照中缩小过滤器重测，并将结果标注为插桩受限 |
| 输出过多 | 减少 Capture Filter 至当前假设相关的最小 API 集；保留过滤器截图和原始 capture |
| 参数/返回值难以解释 | 与 API 官方语义、Procmon/PCAP、模块/线程和内存镜像交叉验证；不要凭名称推断行为 |
| 保存的 capture 无法复读 | 保存原始文件、工具版本、过滤器和截图；不要手工修改原始 capture |

## 实战检查清单

- [ ] 已验证 r13 在同类 Win11 实验环境中的兼容性，并记录 x86/x64 选择。
- [ ] 捕获过滤器最小化且已截图，目标为已授权的隔离实验进程。
- [ ] 已保存原始 capture、哈希、PID/TID、参数/返回值和完整时间基准。
- [ ] 未使用 API 控制、动作断点、内存编辑、自定义监视 DLL 或非授权附加。
- [ ] 关键调用已由 Procmon/Noriben、PCAP/服务日志和 Volatility 3/MemProcFS 交叉验证。

## 官方资料

- [API Monitor 官方下载与功能页](https://www.rohitab.com/apimonitor)
- [API Monitor v2r13 更新记录](https://www.rohitab.com/apimonitor/changelog)
