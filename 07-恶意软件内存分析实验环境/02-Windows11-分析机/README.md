# Windows 11 分析机

## 建设目标

Windows 11 虚拟机负责静态初筛、受控动态观察和内存镜像制作。先确认镜像版本、虚拟化平台、工具版本和快照，再添加工具；不要使用来源不明的整合包或桌面快捷方式代替可验证的软件来源。

## 分层工具集

| 层级 | 图中工具及补充 | 主要产物 | 内存取证关联 |
| --- | --- | --- | --- |
| 系统观察 | System Informer（原 Process Hacker）、Process Explorer、Process Monitor、Autoruns | 进程树、模块、句柄、文件/注册表/线程事件 | 为镜像中的 PID、模块、路径和时间提供运行时对照 |
| 网络观察 | Wireshark、Fiddler、TCPLogView、Network Connections | PCAP、HTTP 会话、TCP 连接 | 对照 socket、DNS 缓存与所属进程 |
| 静态初筛 | PeStudio、Detect It Easy（DIE）、CFF Explorer、PE-bear/Exeinfo PE、HxD、HashMyFiles、Everything | 哈希、PE 元数据、节区和字符串线索 | 帮助解释镜像内模块、映像映射和字符串 |
| 调试与逆向 | x64dbg/x32dbg、WinDbg、Ghidra、FileInsight、CyberChef | 调试笔记、函数/地址与解码结果 | 将线程入口、内存区域和字节上下文还原为可解释证据 |
| 内存与修复 | DumpIt 或经验证的采集工具、Volatility 3、Scylla x86/x64、Imports Fixer | 镜像、插件输出、受控重建记录 | 镜像采集、进程/VAD/模块分析、对异常映像作离线验证 |
| 时间线/差异 | Noriben、Regshot、Timeline Explorer、ProcDOT、BinDiff | Procmon 摘要、注册表差异、时序视图 | 将内存对象放回执行前后的行为上下文 |

`Volatility 2`、旧版 `Process Hacker`、旧 DumpIt 与截图中无法确认来源的 `da.exe`、`UIF`、`iSpy` 等，仅作为历史参考。投入实验前必须记录维护者、下载来源、版本、数字签名或 SHA-256；优先使用 Volatility 3 和 System Informer。

## 安装与基线

1. 更新 Windows 并创建 `win11-clean` 快照；记录版本、架构、内存大小和已启用安全特性。
2. 从官方项目或厂商页面下载工具，保存安装包哈希、签名校验结果和许可证。Microsoft Sysinternals 工具可从 [官方集合](https://learn.microsoft.com/sysinternals/downloads/sysinternals-suite) 获取。
3. 建立 `C:\Lab\Tools`、`C:\Lab\Samples`、`C:\Lab\Evidence` 三个目录；后两者不与宿主机共享。原始样本只读保存，所有工具输出写入 Evidence。
4. 配置 Process Monitor 过滤器与日志目录，启动 [Noriben](https://github.com/Rurik/Noriben) 前确认它调用的是已验证的 `Procmon.exe`。
5. 配置 Wireshark 仅监听实验网卡；启动 Windows 自带防火墙并拒绝非实验网段通信。
6. 对一个无害测试程序完成一次基线：静态初筛、Procmon/Noriben、Wireshark、内存采集和 Volatility 分析。

## 内存采集检查

- 采集前记录运行中的测试程序、PID、命令行和当前网络连接。
- 选择与 Windows 版本兼容且来源可验证的采集工具；完整 RAM 镜像、内核/活动内核转储、进程 dump 的覆盖范围不同。
- 采集后立即计算 SHA-256，并保留工具版本、参数、开始/结束时间和任何报错。
- 使用 [Volatility 3 Windows 教程](https://volatility3.readthedocs.io/en/latest/getting-started-windows-tutorial.html) 进行 `windows.info`、进程树、模块与地址空间的首轮验证。

