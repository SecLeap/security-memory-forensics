# System Informer 实战手册

> 适用范围：隔离 Win11 实验机中，对授权测试程序进行实时进程、线程、模块、句柄、内存区域与连接观察。System Informer 是观察工具，不采集全量内存；界面显示需由采集时点的 Volatility/MemProcFS 输出复核。

[System Informer](https://systeminformer.com/) 是可便携运行的系统观察工具。它的 ExtendedTools 插件在管理员权限下提供磁盘和网络信息；本手册只开启官方内置组件，不加载第三方插件，也不使用终止、挂起、注入、内存编辑等改变运行状态的功能。

## 获取与安装

1. 从官方 Downloads 或官方 GitHub Releases 获取 Setup 或 Portable 包，保留至 C:\Lab\Installers\SystemInformer\，记录 URL、版本、发布包/主程序 SHA-256、签名和 VM 快照。
2. 解压至 C:\Lab\Tools\SystemInformer\。便携使用时，可按官方说明在程序同目录建立设置文件，使案例环境配置随工具目录留存。
3. 用无害程序确认可显示进程树和属性页。管理员权限只用于读取需要提升权限的系统信息；两次观察必须记录权限状态。

    Get-FileHash 'C:\Lab\Installers\SystemInformer\<发布包>' -Algorithm SHA256
    Get-AuthenticodeSignature 'C:\Lab\Tools\SystemInformer\SystemInformer.exe' | Format-List Status,SignerCertificate

## 证据准备

    C:\Lab\Cases\LAB-001\
    ├─ 01-实时观察\SystemInformer\   # 截图、导出、字段记录
    └─ 04-内存镜像与输出\

对每次观察记录 UTC、工具/插件版本、是否管理员、PID、父 PID、进程创建时间、命令行、映像路径、用户/完整性级别和截图文件哈希。始终使用 PID 与创建时间标识对象，避免 PID 复用。

## 使用方法

### 1. 进程树与基本属性

1. 在 Processes 中按树形关系定位测试进程，记录 PID、父进程、命令行、路径、创建时间和用户。
2. 打开 Properties，先保存 Image 页的基本信息；必要时查看 Token、Environment、Services，但不修改权限/服务状态。
3. 将进程树截图与 Procmon 的 Process Create、Process Explorer 或 Volatility pslist/psscan 交叉核对。

### 2. Modules、Threads、Handles、Memory

| 页面 | 记录字段 | 必须复核 |
| --- | --- | --- |
| Modules | 路径、基址、大小、签名、加载时间（若显示） | Volatility dlllist/ldrmodules、磁盘对象哈希 |
| Threads | TID、起始地址、状态、所属模块 | 内存线程插件、模块/VAD、ASLR 基址 |
| Handles | 类型、名称、访问权限、文件/注册表路径 | Procmon 操作、对象可能已关闭的时间差 |
| Memory | 区域起止、保护、类型、映射/私有信息 | VAD、页面权限、线程起始地址和原始字节 |
| Network | 本地/远端地址端口、协议、状态 | PCAP、服务端日志、Volatility 网络对象 |

异常标签只表示“待验证线索”。例如可执行私有区域、无路径模块或异常句柄必须结合 VAD、线程、磁盘/内存字节及采集时点解释，不能单独归为注入。

### 3. 受控导出

对需写入报告的表格，用界面导出或截图保存到案例目录；保存当前列、排序、筛选和时间。不要使用 Suspend、Terminate、Priority、Affinity、Inject DLL、Memory Editor 或服务控制按钮改变观察对象。

## 与内存取证联动

1. 关键行为前记录 PID、模块基址、线程入口、VAD/内存区域与连接；随后制作全量内存镜像并立即计算 SHA-256。
2. 在 Volatility 3/MemProcFS 中记录相同 PID 的命令行、模块、VAD、线程和网络对象，保存完整命令与原始输出。
3. 对地址差异先排查 ASLR、重定位、页面释放、采集延迟与 PID 复用。报告应区分“实时界面观察”和“快照内存对象”。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| 看不到网络/磁盘字段 | 记录是否管理员及 ExtendedTools 状态；不通过未知插件补功能 |
| 模块无路径/基址异常 | 保存截图和时间，复核 VAD/线程/原始字节，不修改进程 |
| 安全软件告警 | 核验官方包与签名，仅隔离 VM 记录现象 |

- [ ] 已记录工具/插件版本、哈希、权限与 VM 快照。
- [ ] 已用 PID 加创建时间标识进程，并保存进程树和属性页证据。
- [ ] 模块、线程、句柄、内存和连接线索均已回查原始日志或内存输出。
- [ ] 未使用任何终止、挂起、注入或内存修改功能。

## 官方资料

- [System Informer 官方说明](https://www.systeminformer.com/readme)
- [System Informer 下载页](https://systeminformer.com/downloads)
