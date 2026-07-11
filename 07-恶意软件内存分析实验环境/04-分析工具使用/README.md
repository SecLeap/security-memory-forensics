# 分析工具使用

本页按“先静态、再动态、后内存”的顺序说明工具组合。所有动态步骤仅适用于断网/隔离实验机上的无害测试程序、公开教学样本或已获授权材料。单个工具的安装、验证和具体使用步骤以 [05-工具与自动化](../../05-工具与自动化/README.md) 的逐工具手册为准，本页不重复维护安装细节。

## 1. 静态初筛：不执行文件

| 工具 | 最小操作 | 输出与下一步 |
| --- | --- | --- |
| HashMyFiles / PowerShell `Get-FileHash` | 计算 SHA-256，记录文件大小与来源 | 样本编号；后续全部日志和镜像使用同一编号 |
| PeStudio、DIE、CFF Explorer、PE-bear/Exeinfo PE | 查看 PE 架构、节区、导入、签名、编译信息和资源 | 标记潜在网络/API、加载器特征和需重点观察的模块 |
| HxD、FileInsight、CyberChef | 仅查看字符串、字节、编码和容器内容 | 记录偏移与解码方法，不直接把字符串当作行为结论 |
| Ghidra | 对副本做函数、字符串和调用关系注释 | 记录函数地址，供 x64dbg/WinDbg 与内存线程入口核对 |

不要因文件名、单个字符串、壳识别或在线情报结果而直接定性；静态初筛的价值是形成动态观察假设。

## 2. 动态观察：先启动记录工具

| 工具 | 启动时机 | 关键过滤/观察 | 保存内容 |
| --- | --- | --- | --- |
| Process Monitor | 测试程序启动前 | 进程名/PID、文件、注册表、进程/线程事件 | 原始 PML 与导出的 CSV；不要只保存截图 |
| Noriben | 测试程序启动前 | 以 Procmon 日志自动生成摘要，人工复核过滤规则 | Noriben 报告、配置、关联 PML |
| System Informer / Process Explorer | 运行期间 | 进程树、命令行、令牌、句柄、模块、线程与内存区域 | PID、模块路径、线程入口和截图/导出 |
| Wireshark | 运行前 | 仅实验网卡；DNS、HTTP、TCP 会话 | PCAP、显示过滤器和时区 |
| Fiddler / TCPLogView | 仅在需要 HTTP/TCP 辅助视图时 | 代理设置或连接变化必须记录 | 会话导出；不将其作为唯一网络证据 |
| Autoruns / Regshot | 运行前后 | 仅比较启动项与注册表变化 | 前后导出/快照差异与时间 |

[Process Monitor 官方文档](https://learn.microsoft.com/sysinternals/downloads/procmon)说明其可实时记录文件系统、注册表及进程/线程活动；[Noriben](https://github.com/Rurik/Noriben) 是对 Procmon 的 Python 包装与摘要工具。两者的过滤结果必须保留原始日志以供复核。

## 3. 内存与调试：建立地址关联

1. 从 System Informer/Process Explorer 记录目标 PID、命令行、加载模块、线程起始地址和异常内存区域。
2. 在执行前后（或关键行为出现后）使用已验证的采集工具创建镜像，计算 SHA-256，并登记工具/版本/参数。
3. 用 Volatility 3 依次检查镜像信息、进程树、命令行、模块、线程、VAD/内存映射和网络对象。
4. 若发现异常地址，将其与 x64dbg/WinDbg 的调试笔记、Ghidra 函数地址、Procmon 时间线交叉核对。
5. Scylla、Imports Fixer 只用于离线理解受控样本/镜像中的 PE 映像布局；记录输入副本、输出哈希和重建假设，绝不覆盖原文件。

## 4. 工具版本与来源

- System Informer：使用[官方项目](https://github.com/winsiderss/systeminformer)。它是 Process Hacker 的后继选择；两者不必并装。
- Sysinternals：Process Explorer、Process Monitor、Autoruns、WinDbg 相关资料从 [Microsoft Sysinternals](https://learn.microsoft.com/sysinternals/) 和 [Windows Debugger](https://learn.microsoft.com/windows-hardware/drivers/debugger/) 获取。
- Wireshark：[官方文档](https://www.wireshark.org/docs/)；只在实验网卡上抓包。
- x64dbg：[官方项目](https://github.com/x64dbg/x64dbg)；Ghidra：[官方项目](https://github.com/NationalSecurityAgency/ghidra)。
- Volatility：使用 [Volatility 3](https://volatility3.readthedocs.io/en/latest/)。Volatility 2 仅用于复现旧资料，必须标注其适用版本与限制。
- Volatility 3 的安装、符号、三端插件与排错详见 [仓库实战手册](../../05-工具与自动化/02-Volatility3-实战手册.md)。

## 5. 统一命名

```text
<案例编号>_<UTC时间>_<主机>_<证据类型>_<工具版本>.<扩展名>
LAB-001_20260711T090000Z_WIN11_procmon_4.01.pml
LAB-001_20260711T090500Z_WIN11_memory_acquirer-x.raw
LAB-001_20260711T090000Z_DEBIAN_inetsim.log
```
