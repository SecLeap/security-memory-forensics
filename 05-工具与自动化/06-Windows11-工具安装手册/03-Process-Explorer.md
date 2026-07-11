# Process Explorer 实战手册

> 适用范围：隔离 Win11 实验机中，使用 Sysinternals Process Explorer 观察实时进程树、句柄、DLL/内存映射和线程。它是 System Informer 的替代/互补观察器，不应与其同时做重复干预；默认只读观察。

[Process Explorer](https://learn.microsoft.com/sysinternals/downloads/process-explorer) 的下方面板可切换为 Handle 或 DLL 模式，并支持按句柄/DLL 搜索。安装包内含可执行文件；记录发布包、procexp.exe、版本、签名与 SHA-256，解压至 C:\Lab\Tools\Sysinternals\ProcessExplorer\。

## 观察前准备

1. 在 VM 快照后，以无害测试程序确认能查看 Properties、下方面板和搜索。
2. 记录当前 UTC、工具版本、管理员权限、目标进程 PID、创建时间、命令行和父 PID。
3. System Informer 已作为主观察器时，Process Explorer 仅用于其下方面板/搜索特长，避免两套截图出现不一致却无时间说明。

## 使用方法

### 1. 进程树与 Image 属性

1. 在上方面板定位进程树，确认映像路径、PID、父 PID、用户和创建时间。
2. 打开 Properties 的 Image 页，记录命令行、当前目录、签名/校验、启动时间和父进程；签名状态是工具提示，不能代替独立签名验证。
3. 导出或截图必须包含 PID、创建时间和 UTC，避免同名/PID 复用混淆。

### 2. 下方面板、搜索和线程

| 功能 | 合法用途 | 必须避免 |
| --- | --- | --- |
| Handle 模式 | 定位文件、注册表、事件等已打开对象 | 关闭句柄或改变对象状态 |
| DLL 模式 | 记录 DLL 与 memory-mapped file 的路径、基址、大小 | 仅凭无路径/未验证 DLL 下结论 |
| Find Handle/DLL | 从已知路径/DLL 名回查相关进程 | 将搜索结果当作完整历史记录 |
| Threads 页 | 记录 TID、起始地址、状态与所属模块 | Suspend/Resume/Kill 线程 |

对要报告的每项保留“页面、字段、时间、PID、输入/对象路径、截图哈希”。Process Explorer 只能反映实时状态；缺失的句柄或 DLL 可能在观察前/后已关闭或卸载。

## 与内存取证联动

1. 记录模块基址、线程起始地址和句柄路径后立即或在关键时点采集全量内存镜像。
2. 以镜像 SHA-256、Volatility/MemProcFS 命令和 PID 复核 dlllist/ldrmodules、VAD、线程、handle 对象。
3. 模块基址不同先解释 ASLR；映射文件、私有 VAD 和手工映像需要原始字节与线程上下文共同支持。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| 下方面板无内容 | 确认已选定进程和模式，记录权限状态，不重启/干预目标 |
| 搜索结果过多 | 以完整路径、PID、创建时间和时间窗缩小；保存搜索词 |
| 签名未知 | 记录提示并独立核验文件副本，不访问未知在线服务 |

- [ ] 工具包/主程序、输入对象和截图/导出已建立哈希链。
- [ ] 已记录 PID、创建时间、命令行、模块/句柄/线程字段与 UTC。
- [ ] 已用内存镜像和原始日志复核关键实时观察。
- [ ] 未关闭句柄、终止/挂起进程或线程、修改优先级/亲和性。

## 官方资料

- [Process Explorer 官方说明](https://learn.microsoft.com/sysinternals/downloads/process-explorer)
