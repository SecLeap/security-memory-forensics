# TaskExplorer 实战手册

> 适用范围：隔离 Win11 恶意软件内存分析实验中，对**正在运行的受控测试程序**进行只读观察并记录实时线索。TaskExplorer 不是离线内存镜像解析器；关键时点仍须采集全量 RAM 镜像，再由 Volatility 3 和 MemProcFS 独立验证。

[TaskExplorer](https://xanasoft.com/TaskExplorer/) 是 Xanasoft 的 Windows 进程与系统监视工具，可展示进程、线程栈、模块、内存、句柄、socket、令牌和环境等面板。官方说明也列出内存编辑、DLL 卸载/注入等控制能力；这些功能不属于本仓库的取证流程，**一律不使用**。本手册只覆盖观察、截图、记录和与镜像取证的关联。

## 获取与安装

### 1. 下载、校验与安装方式

1. 通过 [Xanasoft 官方下载页](https://xanasoft.com/taskexplorer-downloads/) 或其链接的 [GitHub Releases](https://github.com/DavidXanatos/TaskExplorer/releases) 获取安装包或 portable 包；不要使用第三方重打包。
2. 将下载原件保存到 `C:\Lab\Installers\TaskExplorer\`；portable 包解压至 `C:\Lab\Tools\TaskExplorer\`，安装版只部署在隔离分析 VM。
3. 记录版本/发布标签、下载 URL、文件名、SHA-256、签名状态和下载时间，再创建 VM 快照。官方页面说明 portable 包可直接启动 `TaskExplorer.exe`；完整系统进程可见性建议以管理员权限运行。

```powershell
Get-FileHash 'C:\Lab\Installers\TaskExplorer\<发布包>' -Algorithm SHA256
Get-AuthenticodeSignature 'C:\Lab\Tools\TaskExplorer\TaskExplorer.exe' |
  Format-List Status,StatusMessage,SignerCertificate
Start-Process -FilePath 'C:\Lab\Tools\TaskExplorer\TaskExplorer.exe' -Verb RunAs
```

TaskExplorer 可能使用其依赖的系统组件/驱动以提供深度可见性。安装或管理员启动是实验环境中的一次系统变更，须在运行样本前完成、记录并包含在基线快照中；不要在案例关键行为期间更新程序或启用在线更新。

### 2. 最小验证

在未运行测试程序时启动 TaskExplorer：

1. 确认能看到进程列表和系统资源概览。
2. 选择已知良性进程，确认可打开详细面板（至少线程、模块、内存或句柄之一）。
3. 将版本、管理员状态、可见面板和时间写入实验基线记录。
4. 验证截图可保存至案例目录；不以 TaskExplorer 的临时视图替代后续 RAM 镜像或原始日志。

## 观察前准备与边界

### 1. 案例目录与最小记录字段

```text
C:\Lab\Cases\LAB-001\
├─ 01-静态初筛\
├─ 02-TaskExplorer-记录\
├─ 03-Procmon-Noriben\
├─ 04-网络记录\
└─ 05-内存镜像\
```

每次观察至少记录：

| 字段 | 说明 |
| --- | --- |
| 时间与时区 | 启动、选定进程、截图和采集镜像的时间基准 |
| TaskExplorer | 版本、SHA-256、管理员状态、是否使用 portable/安装版 |
| 进程标识 | PID、父 PID、名称、映像路径、命令行、创建时间（界面可见时） |
| 观察对象 | 线程、模块、内存区域、句柄、socket、令牌或环境变量 |
| 位置 | 线程起始地址、模块基址、内存地址范围、句柄值或五元组（如适用） |
| 证据 | 原始截图、手工笔记、后续镜像 SHA-256 与 Volatility 3/MemProcFS 互证状态 |

### 2. 明确禁止的操作

在本仓库的内存取证实验中，TaskExplorer 仅为只读观察窗口。禁止：

- 编辑进程内存、写入字节、修改内存保护或搜索后替换；
- 注入/卸载 DLL、创建/终止/挂起线程、结束进程或改变优先级；
- 关闭句柄、调整令牌/权限、修改环境变量或服务/驱动；
- 对非授权终端、生产系统或真实用户会话进行监控/控制。

如果确需改变实验状态，应在受控测试方案中先获得授权、创建快照，并使用独立实验步骤；该改变产生的证据不能与纯观察阶段混为一谈。

## 使用方法

### 1. 基线—运行—采集工作流

1. 在实验 VM 快照完成后，以管理员身份启动 TaskExplorer、Procmon/Noriben 和网络记录工具；确认所用网卡为隔离实验网卡。
2. 未启动测试程序前，记录基线进程树、系统资源状态与目标父进程。
3. 启动受控的良性测试程序或已授权教学材料后，按 PID 锁定目标进程；不要仅凭相同的进程名判断对象。
4. 在关键时间点记录进程概要与所需面板；用案例号、PID、UTC 时间命名截图，例如 `LAB-001_PID-1234_20260711T031500Z_modules.png`。
5. 立即按 [WinPmem 实战手册](14-WinPmem.md) 采集全量内存镜像，计算 SHA-256；TaskExplorer 截图只解释“采集前的实时观察”，不能证明镜像中的全部状态。
6. 在分析机以 Volatility 3 与 MemProcFS 解析同一镜像，对齐 PID、时间、地址和对象关系。

### 2. 进程与线程面板

1. 在进程树中记录 PID、父子关系、映像路径、命令行和创建时间（若可见）。
2. 打开目标进程的线程面板，记录线程 ID、状态、CPU 活动、起始地址和可用的栈帧摘要。
3. 对非模块映射、私有可执行区域或异常起始地址，仅记录地址/时间并标为“待验证”；不要在 TaskExplorer 中跳转后修改、暂停或终止线程。
4. 在 Volatility 3 中复核进程、命令行、线程及其关联 VAD；地址比较前排查 ASLR、重定位、采集时间差和位数。

### 3. 模块、内存与句柄面板

| 面板 | 记录内容 | 后续镜像复核 |
| --- | --- | --- |
| Modules | DLL/映射文件路径、基址、大小、签名/版本（若可见） | Volatility 模块列表、VAD、原始 PE 字节与文件哈希 |
| Memory | 区域起止地址、权限、类型、映射来源、提交大小 | Volatility VAD/内存映射；重点检查私有可执行区域与线程入口关联 |
| Handles | 文件、注册表、进程、线程、节等对象及句柄值 | 句柄/对象插件、Procmon 事件、导出物来源 |
| Token/Environment | 用户、完整性/权限线索、环境变量 | 进程令牌/命令行与内存对象；不在界面中修改 |

TaskExplorer 的内存面板可提供实时定位线索，但不是写时冻结的证据。所有关键地址均需在同一时点附近采集的全量 RAM 镜像中再次确认。

### 4. Socket 与系统概览

1. 在目标进程 socket 面板记录本地/远端地址、端口、协议、状态、PID 与观察时间；截取完整表格而非只保存一个 IP。
2. 同步保存 Wireshark/FakeNet-NG 或 Debian 模拟服务日志，记录时区和接口。
3. 在 Volatility 3 网络相关输出中复核 socket 对象，在 PCAP/服务日志中复核实际通信。TaskExplorer 显示的瞬时连接、ETW 辅助数据或速率不应单独作为网络行为结论。
4. 系统概览中的 CPU、内存、磁盘、网络曲线仅用于选择采集时机和解释噪声，不用作恶意行为判定。

### 5. 截图与手工导出

优先保留界面原貌截图，并在同一目录写一份文本索引：截图文件名、时间、PID、面板、地址/五元组、操作者和工具版本。若当前 TaskExplorer 版本提供导出功能，可将导出文件视为补充材料；仍要保留截图、记录导出格式和文件哈希，避免依赖未固定的界面/导出格式。

```powershell
$record = 'C:\Lab\Cases\LAB-001\02-TaskExplorer-记录'
Get-ChildItem $record -Recurse -File | Get-FileHash -Algorithm SHA256 |
  Export-Csv "$record\LAB-001-taskexplorer-hashes.csv" -NoTypeInformation -Encoding utf8
```

## 与内存取证的联合分析

### 场景一：实时线程线索与 VAD 互证

1. TaskExplorer 记录目标 PID、线程 ID、线程起始地址及其所在内存区域。
2. 紧接着采集 RAM 镜像，保存采集开始/结束时间和 SHA-256。
3. Volatility 3 检查该进程的线程、VAD、模块、保护属性与地址范围；MemProcFS 从进程/内存映射视图交叉验证。
4. 如果线程起始点不属于常规模块，导出可验证的工作副本，用 PEStudio、DiE、FLOSS 或 capa 辅助解释格式/字符串/能力；报告中保留“实时观察”与“镜像验证”两个证据层级。

### 场景二：实时 socket 线索与网络证据链

1. TaskExplorer 记录 PID、连接五元组和时间。
2. Wireshark 或 FakeNet-NG 记录同时间段 PCAP/模拟服务日志；Procmon/Noriben 记录关联进程活动。
3. 采集内存镜像后，以 Volatility 3 网络对象、命令行和进程关系复核。
4. 只有 PID、时间和五元组/域名能相互对齐时，才描述为“该进程在该时间段关联到该通信”。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 看不到完整进程/模块/句柄信息 | 确认已在隔离 VM 以管理员权限运行；记录可见性限制，不绕过系统保护或加载来源不明驱动 |
| 进程/地址在截图与镜像中不同 | 检查采集时间差、ASLR、进程退出/重启、PID 重用和镜像哈希；不要选择性忽略差异 |
| 启动后被防病毒告警 | 仅从官方渠道重新校验发布包，记录告警；不在生产系统设置永久排除项 |
| 在线更新提示 | 案例期间不更新；记录当前版本，等案例完成后在干净更新流程中评估新版本 |
| 界面出现编辑、注入或终止选项 | 不使用；本手册仅允许查看、截图、记录和后续镜像验证 |

## 实战检查清单

- [ ] 工具来自 Xanasoft/GitHub 官方发布页，且已记录版本、SHA-256、签名状态与 VM 快照。
- [ ] 仅在隔离、已授权的实验 VM 中以管理员身份观察。
- [ ] 已记录 PID、时间、进程树、线程/地址、模块/VAD 线索和 socket 信息。
- [ ] 未执行编辑内存、注入/卸载 DLL、结束/挂起进程或线程、关闭句柄等控制操作。
- [ ] 已在关键时间点采集全量 RAM 镜像，并以 Volatility 3/MemProcFS 复核关键线索。
- [ ] 截图、导出物、工具版本和哈希清单已保存在案例目录。

## 官方资料

- [TaskExplorer 下载与系统要求](https://xanasoft.com/taskexplorer-downloads/)
- [TaskExplorer 功能概览](https://xanasoft.com/TaskExplorer/)
- [TaskExplorer GitHub Releases](https://github.com/DavidXanatos/TaskExplorer/releases)
