# Windows 终端取证

## 学习主线

先掌握 `EPROCESS → ETHREAD → PEB/TEB → VAD → 模块/句柄` 的关系，再学习 Windows dump 格式、PDB 符号与 Volatility 输出。不要把内核转储、活动内核转储和完整物理内存镜像视为等价物：它们的覆盖范围不同。

## 推荐资料

- [Volatility 3 Windows 教程](https://volatility3.readthedocs.io/en/latest/getting-started-windows-tutorial.html)：从 `windows.info`、进程和树状枚举开始。
- [Windows 完整内存转储说明](https://learn.microsoft.com/windows-hardware/drivers/debugger/complete-memory-dump)：了解页文件、默认路径与覆盖范围。
- [任务管理器活动内核转储](https://learn.microsoft.com/windows-hardware/drivers/debugger/task-manager-live-dump)：适用于实验中理解 live kernel dump 的边界，不等同全量 RAM 镜像。
- [WinPmem](https://github.com/Velocidex/WinPmem)：跨平台内存采集项目；使用前先核对 release、签名、目标 Windows 版本和驱动加载限制。

## 实验顺序

1. 在 Windows 虚拟机记录系统版本、架构、内存容量和已加载测试程序。
2. 先用公开样本执行 `windows.info`、`windows.pslist`、`windows.pstree`、`windows.dlllist`。
3. 再采集自己的实验镜像，比较已知进程、模块和命令行是否可被正确还原。
4. 保存每次运行的插件版本、符号下载状态、命令与原始输出。

## 待办

- [ ] Windows 内核、对象管理器、EPROCESS、ETHREAD、PEB/TEB、句柄和令牌。
- [ ] VAD、页表、工作集、内存映射、加载器列表和 DLL 映像。
- [ ] 内核驱动、回调例程、对象目录、注册表 hive 的内存表示。
- [ ] Windows 内存转储格式、PDB 符号、KASLR 与版本兼容性。
- [ ] Windows 10/11、Server 版本差异与 VBS/Credential Guard 对采集和解析的影响。
