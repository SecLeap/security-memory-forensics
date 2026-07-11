# Windows 11 分析工具实战手册

本手册组织 Win11 恶意软件内存分析环境中使用的工具。全部操作只适用于隔离虚拟机和已授权材料；先创建快照、启动记录工具，再运行无害测试程序或公开教学样本。

单个工具的安装、验证、使用方法与场景以 [Windows11 逐工具手册](06-Windows11-工具安装手册/README.md) 为准；本页只保留工具分层和组合关系。

## 工具总表

| 阶段 | 工具 | 用途 | 必须保留的输出 |
| --- | --- | --- | --- |
| 文件初筛 | HashMyFiles、PeStudio、DIE、CFF Explorer、PE-bear/Exeinfo PE、HxD、FileInsight、CyberChef | 哈希、PE 结构、字符串、编码和节区线索 | SHA-256、工具版本、偏移/规则与截图或导出 |
| 运行观察 | Process Monitor、Noriben、System Informer、Process Explorer、Autoruns、Regshot | 进程树、文件/注册表/线程事件、模块、句柄和启动项差异 | PML、CSV、Noriben 报告、前后 Regshot、PID 清单 |
| 网络观察 | Wireshark、Fiddler、TCPLogView、Network Connections | DNS、HTTP、TCP 会话与连接归属 | PCAP、会话导出、显示过滤器、五元组与时区 |
| 调试/逆向 | x64dbg/x32dbg、WinDbg、Ghidra、Scylla、Imports Fixer | 函数、线程入口、模块基址、PE 映像布局 | 调试笔记、地址、输入/输出副本哈希 |
| 内存取证 | 经验证的采集工具、Volatility 3 | RAM 镜像、进程/VAD/模块/socket 分析 | 镜像 SHA-256、采集记录、插件命令和完整输出 |

来自旧环境截图的 Volatility 2、Process Hacker、DumpIt 及来源不明的 `da.exe`、`UIF`、`iSpy` 不应默认安装。先核验维护者、下载页面、数字签名或 SHA-256；日常分析优先使用 Volatility 3 与 System Informer。

## 静态初筛手册

1. 将原始文件复制到 `C:\Lab\Samples\<案例编号>`，设置为只读；记录 SHA-256、来源、大小和接触时间。
2. 使用 PeStudio、DIE 或 CFF Explorer 查看 PE 架构、节区、导入、签名、资源和字符串；只记录线索，不把壳/字符串识别视为行为事实。
3. 用 HxD/FileInsight 定位已关注的字节或偏移；用 CyberChef 记录解码配方和输入/输出哈希。
4. 在 Ghidra 中为样本副本标记函数和字符串地址；这些地址后续用来解释调试器或内存镜像的模块/线程位置。

## 动态观察手册

### Process Monitor 与 Noriben

1. 以管理员身份启动 Procmon，先停止捕获并清空历史事件；设置只聚焦测试 PID/进程树的过滤器。
2. 把原始 PML 写入案例目录。启动测试前再开始捕获；结束后立即停止，避免无关系统噪声。
3. 需要摘要时，使用 Noriben 包装同一份经验证的 `Procmon.exe`；保留 Noriben 配置、文本/CSV 报告和原始 PML。
4. 用 PID、时间、路径和操作类型筛选出待验证现象，再回到 System Informer/Volatility 查询对象。

### System Informer / Process Explorer / Autoruns / Regshot

- System Informer（Process Hacker 的后继）或 Process Explorer：记录进程树、命令行、令牌、加载模块、句柄、线程入口和私有内存。二者任选其一作为主观察工具，避免重复干扰。
- Autoruns：实验前后导出启动项快照；只比较差异，不在未理解条目的情况下删除或禁用系统项。
- Regshot：在测试前后创建注册表/目录差异快照；将差异路径关联到 Procmon 时间和目标 PID。

## 网络观察手册

1. Wireshark 只选择实验虚拟网卡；从启动测试前开始抓包，停止后保存 PCAPNG、抓取接口和显示过滤器。
2. 若采用 Fiddler，记录代理设置和生效时间；HTTPS 解密只在自建无害服务与明确授权条件下使用。
3. TCPLogView/Network Connections 仅作快速辅助视图，网络结论至少由 PCAP 或 Debian 服务端日志复核。
4. 将 DNS 域名、五元组、请求时间和 PID 回填至 Case Timeline；再在 Volatility 3 中检查对应的 socket/进程对象。

## 内存与调试联动手册

1. 记录运行时 PID、模块基址、线程入口与可疑内存区域。
2. 在关键行为期间制作内存镜像，立即计算 SHA-256；不要依赖某个进程 dump 代替全量内存镜像。
3. 按 [Volatility 3 实战手册](02-Volatility3-实战手册.md) 运行信息、进程、命令行、模块、VAD、网络和异常内存区域插件。
4. 将 Volatility 的对象地址与 x64dbg/WinDbg、Ghidra、Procmon 和 Wireshark 的记录对齐；地址差异需先排查 ASLR、重定位和采集时间。

## 工具来源

- [Sysinternals](https://learn.microsoft.com/sysinternals/)：Process Monitor、Process Explorer、Autoruns。
- [System Informer](https://github.com/winsiderss/systeminformer)
- [Noriben](https://github.com/Rurik/Noriben)
- [Wireshark](https://www.wireshark.org/docs/)｜[x64dbg](https://github.com/x64dbg/x64dbg)｜[Ghidra](https://github.com/NationalSecurityAgency/ghidra)
