# 联合分析场景

## 场景一：DNS 请求与 HTTP 访问的内存归因

**目标**：在无害测试程序中建立一次受控 DNS→HTTP 行为，学习将 Debian 侧服务日志、Windows PCAP、Procmon 和内存 socket 关联到同一 PID。

| 阶段 | Windows 11 | Debian | 内存取证问题 |
| --- | --- | --- | --- |
| 准备 | 启动 Procmon/Noriben、Wireshark，记录基线 PID | 选择“DNS/HTTP 分离”模式，启动 FakeDNS 与 Apache | 运行前是否已有相同连接/缓存？ |
| 触发 | 运行无害测试程序 | 保存 DNS 与 HTTP 日志 | 哪个 PID 发起请求？域名如何解析？ |
| 固化 | 记录 PID、命令行和连接；制作镜像 | 停止服务并导出日志/PCAP | 镜像内 socket、DNS 缓存、进程命令行是否一致？ |
| 验证 | Volatility 进程/网络插件、必要时字符串上下文 | 对齐日志时区和请求 ID | 连接是否可能已关闭/对象已回收？ |

**完成标准**：报告能以时间、五元组、PID、对象地址四个字段关联至少两种独立数据源，并说明缺失数据的原因。

## 场景二：文件/注册表变化与异常内存区域

**目标**：用无害测试程序产生可预测的文件或注册表写入，然后比较 Procmon、Regshot、System Informer 与内存映射。

1. 静态初筛测试程序并记录 SHA-256、PE 架构和预期写入路径。
2. 运行前启动 Procmon/Noriben，使用 Regshot 创建前置快照。
3. 运行程序，记录 PID、子进程、模块和线程；结束后导出 Procmon 并生成后置 Regshot。
4. 关键行为完成后制作内存镜像；使用 Volatility 对照进程树、命令行、VAD/内存映射和加载模块。
5. 如存在匿名可执行页或映像不一致，记录地址、保护属性、线程入口与原始字节上下文；与正常对照程序比较，避免仅凭 RWX 定性。

## 场景三：多协议模拟与内存可见性边界

**目标**：使用 INetSim 模拟多种服务，理解“服务端日志存在”与“内存中仍可见网络对象”不是同一结论。

1. 选择“全服务模拟”模式，仅运行 INetSim；关闭 FakeDNS 和 Apache，避免端口冲突。
2. 在 Debian 保存 INetSim session/report、服务日志和 PCAP；在 Windows 保存 Procmon、Wireshark 和进程信息。
3. 在连接进行中制作一次镜像；连接完成/关闭后再制作一次镜像。
4. 分别分析两份镜像中的 socket、进程和字符串，解释对象回收、缓存和采集时机带来的差异。

## 场景四：内存中可疑映像的静态—动态闭环

**目标**：把静态元数据、调试地址、内存模块/VAD 与运行事件闭环；不要求修改或规避任何安全机制。

1. 用 DIE/PeStudio/Ghidra 对无害测试二进制副本建立模块、函数和字符串笔记。
2. 用 x64dbg 或 WinDbg 在隔离机调试该副本，记录模块基址和测试线程入口；不在真实业务程序上调试。
3. 使用 Process Explorer/System Informer 记录运行时模块、线程和内存区；同时保存 Procmon 时间线。
4. 制作镜像并以 Volatility 对照模块加载列表、VAD、线程和命令行。
5. 若地址不同，解释 ASLR、重定位、镜像格式或采集时间差，而非直接认定工具错误。

## 场景选择矩阵

| 想回答的问题 | 首选工具组合 | 内存侧最终验证 |
| --- | --- | --- |
| 哪个进程请求了哪个域名？ | FakeDNS/INetSim + Wireshark + Procmon | socket、DNS 缓存、进程命令行 |
| 哪个进程创建了文件或改动注册表？ | Procmon/Noriben + Regshot + System Informer | 进程、句柄、VAD、模块与时间对齐 |
| 某个连接是否仍然活跃？ | INetSim/Apache 日志 + Wireshark | socket 状态与所属进程；注明采集时刻 |
| 某内存映像从何而来？ | PeStudio/DIE/Ghidra + x64dbg/WinDbg | 模块列表、VAD、线程入口和字节上下文 |

