# Process Monitor（Procmon）实战手册

> 适用范围：隔离 Win11 实验机中，对授权测试程序的进程、文件、注册表、映像加载和网络相关事件建立原始 PML 记录。Procmon 记录的是捕获窗口内的系统事件，不表示对象在内存快照中仍存在，也不自动归因行为意图。

## 获取与安装

从 [Microsoft Sysinternals Process Monitor](https://learn.microsoft.com/sysinternals/downloads/procmon) 获取便携包，解压至 C:\Lab\Tools\Sysinternals\Procmon\。记录发布包、Procmon.exe 的 SHA-256、版本、签名、系统版本和 VM 快照。Noriben 如需调用 Procmon，必须指向该同一已核验副本。

## 采集前设置

1. 以管理员身份启动后立即停止捕获并清空已有事件；记录本机时区与 UTC 偏移。
2. 建立聚焦目标 PID/进程树的过滤器，保留 Process Create/Exit、Load Image、CreateFile/WriteFile、RegCreateKey/RegSetValue 及案件所需操作；避免无边界的全系统长时间捕获。
3. 保存过滤器配置、显示列和设置截图。先将 PML 目标写入案例目录，确认磁盘空间与循环缓冲设置。

    C:\Lab\Cases\LAB-001\01-动态原始记录\Procmon\
    ├─ LAB-001.pml
    ├─ LAB-001.csv
    ├─ LAB-001-filter.pmc
    └─ LAB-001-采集说明.md

## 使用方法

### 1. 受控捕获

1. 记录启动测试前的 UTC 时间，开始捕获后再运行授权测试。
2. 测试结束立刻停止捕获，保存原始 PML；随后从同一 PML 导出 CSV 供 Timeline Explorer/ProcDOT 使用。
3. 记录输入程序哈希、启动命令、目标 PID、过滤器、开始/结束时间、PML/CSV 哈希。不要只保留 CSV。

### 2. 事件阅读与复核

| 事件 | 记录内容 | 结论边界 |
| --- | --- | --- |
| Process Create/Exit | PID、父 PID、命令行、时间 | 仅为观察到的生命周期事件 |
| Load Image | 映像路径、基址/细节、Result | 不等于模块仍在镜像中 |
| CreateFile/WriteFile | 路径、操作、Result、Detail | 必须确认成功/失败和实际写入语义 |
| RegSetValue 等 | 键、值、Result、Detail | 与 Regshot 前后差异交叉验证 |
| 网络相关项 | 地址、端口、操作/时间 | 以 PCAP/服务端日志确定会话和数据内容 |

逐条打开关键事件属性，保留完整路径、Result、Detail、PID 和时间；过滤或排除噪声时保存规则，不手工删除原始 PML 行。

## 与内存取证联动

在关键事件时间窗内采集内存：用 PID、命令行、映像路径、模块基址、文件/注册表路径作为线索，复核 Volatility/MemProcFS 进程、模块、VAD、句柄和网络对象。已退出进程、已卸载 DLL、关闭句柄和关闭连接可能不会出现在快照中；这属于时间差，不可据此否定 PML。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| 事件极多 | 缩小 PID/进程树和时间窗，重新受控采集；原 PML 不丢弃 |
| 目标进程缺失 | 检查捕获开始时间、过滤器、PID 复用和权限 |
| CSV 与 PML 不一致 | 回到原始 PML 核对导出列/过滤器，CSV 仅是派生物 |

- [ ] 原始 PML、CSV、过滤器、时间和哈希均已保存。
- [ ] 所有关键事件均记录 PID、Result、Detail 和完整路径。
- [ ] 已用 PCAP、Regshot、静态对象或内存输出完成必要复核。
- [ ] 未把 Procmon 的单个事件直接表述为持久化、执行或恶意结论。

## 官方资料

- [Process Monitor 官方下载与说明](https://learn.microsoft.com/sysinternals/downloads/procmon)
