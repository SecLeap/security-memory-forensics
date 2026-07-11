# Volatility 3 实战手册

Volatility 3 是本仓库的首选离线内存分析框架。本手册只分析已合法取得的内存镜像副本；原始镜像保持只读并单独保存哈希。插件结果是待验证的观察，不是自动定性结论。

## 0. 使用前检查

```text
镜像 SHA-256 已登记
系统/内核版本、架构、镜像格式已记录
分析工作站和 Python 环境版本已记录
输出目录与符号目录已创建，且不与原始镜像混放
```

建议目录：

```text
案例编号/
  原始镜像/         # 只读
  哈希与元数据/
  符号/
  volatility-原始输出/
  volatility-结构化输出/
  提取文件/         # 仅存放插件显式导出的副本
```

## 1. 安装与版本固化

Volatility 3 当前官方文档为 2.28.1；项目要求 Python 3.8 或更高版本。使用独立虚拟环境，避免影响系统 Python：

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
# Linux/macOS: source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install volatility3
vol -h
```

将 `vol -h`、`python --version`、`python -m pip show volatility3` 的输出保存到案例目录。若使用源码版，应记录 Git commit；不要混用旧版 Volatility 2 的 profile、插件命名或输出解释。

官方入口：[Volatility 3 文档](https://volatility3.readthedocs.io/en/latest/)｜[项目源码与安装说明](https://github.com/volatilityfoundation/volatility3)

## 2. 符号与镜像识别

| 平台 | 首先执行 | 符号要点 | 常见误区 |
| --- | --- | --- | --- |
| Windows | `windows.info` | 框架可按需下载/缓存 Windows PDB 符号 | 以为任何 `.dmp` 都是完整物理 RAM；转储类型决定可见范围 |
| Linux | `linux.banners` | 通常需要与运行内核匹配的 ISF；由带 DWARF 的 `vmlinux` 等资料经 `dwarf2json` 生成 | 只依据发行版名称选择符号，忽略内核构建 ID/版本 |
| macOS | `mac.pslist` 前先确认镜像与符号 | 通常需为目标版本准备 ISF；插件支持与维护有限 | 将旧 Intel/macOS 经验套用到现代 Apple Silicon 系统 |

Windows、Linux、macOS 的符号表发现与生成流程以[官方符号表文档](https://volatility3.readthedocs.io/en/latest/symbol-tables.html)为准。Linux/macOS 符号不匹配时，先保留报错和 banner，再补齐内核/调试资料；不要用不相干符号表“凑出结果”。

## 3. 通用运行方式与归档

将 `<镜像>` 替换为镜像副本的绝对路径；将每个插件的完整输出保存，不只摘录可疑行：

```bash
vol -f <镜像> <插件名> > volatility-原始输出/<插件名>.txt
vol -f <镜像> -r csv <插件名> > volatility-结构化输出/<插件名>.csv
```

先运行 `vol <插件名> -h` 确认当前版本的参数。只有插件明确支持文件导出时才使用 `-o <提取目录>`；提取结果应计算哈希，并关联原镜像、插件和参数。

## 4. Windows 基线插件路径

```bash
vol -f <镜像> windows.info
vol -f <镜像> windows.pslist
vol -f <镜像> windows.pstree
vol -f <镜像> windows.cmdline
vol -f <镜像> windows.dlllist --pid <PID>
vol -f <镜像> windows.vadinfo --pid <PID>
vol -f <镜像> windows.netscan
vol -f <镜像> windows.malfind
```

解释顺序：

1. `windows.info` 通过后再信任后续对象解析。
2. 以 `pslist` 与 `pstree` 建立 PID/父子关系，再以 `cmdline`、`dlllist`、`vadinfo` 深入特定 PID。
3. 将 `netscan` 的网络对象与 Win11 的 Wireshark、Procmon、System Informer 记录按 PID、五元组和时间对齐。
4. `malfind` 的命中只提示“需要检查的内存区域”；还需验证 VAD 属性、线程入口、模块来源和字节上下文。

完整插件与示例请参阅 [Windows 教程](https://volatility3.readthedocs.io/en/latest/getting-started-windows-tutorial.html)。

## 5. Linux 基线插件路径

```bash
vol -f <镜像> linux.banners
vol -f <镜像> linux.boottime
vol -f <镜像> linux.pslist
vol -f <镜像> linux.pstree
vol -f <镜像> linux.lsof
vol -f <镜像> linux.ip.Addr
vol -f <镜像> linux.bash
vol -f <镜像> linux.malfind
```

先确认 banner 与符号/内核匹配，再分析 `task_struct`、进程树、打开文件、socket 和 VMA。Linux 中空输出尤其要谨慎：镜像来源、内核配置、符号、对象回收和插件支持都可能影响结果。参考 [Linux 教程](https://volatility3.readthedocs.io/en/latest/getting-started-linux-tutorial.html)。

## 6. macOS 基线插件路径

```bash
vol -f <镜像> mac.pslist
vol -f <镜像> mac.pstree
vol -f <镜像> mac.ifconfig
vol -f <镜像> mac.bash
```

macOS 分析必须同时登记 macOS 版本、内核版本、硬件架构、采集方式和 ISF 来源。Volatility 官方说明 macOS 插件虽可用，但维护有限；先用公开镜像复现实验，再评估目标镜像兼容性。详见 [macOS 教程](https://volatility3.readthedocs.io/en/latest/getting-started-mac-tutorial.html)。

## 7. 与 Win11 / Debian 实验室结合

| 实验室证据 | Volatility 3 验证路径 | 必须写明的边界 |
| --- | --- | --- |
| Procmon/Noriben 中的 PID、命令行、模块 | Windows 进程、命令行、DLL 与 VAD 插件 | 采集前后 PID 可复用；以时间和对象地址区分 |
| Wireshark / FakeDNS / Apache / INetSim 日志 | Windows `netscan` 或 Linux IP/socket 相关插件 | 连接可能在采集前关闭；内存不可见不等于服务端日志错误 |
| System Informer 的线程/内存区域 | 线程、VAD、模块和原始字节交叉检查 | 地址随机化与采集时间差会导致基址不同 |
| Debian AVML/LiME 镜像 | `linux.banners` 后的进程、文件、网络与 VMA | 内核、调试信息和符号必须匹配 |

## 8. 常见失败与处理顺序

| 现象 | 优先排查 | 不应做的事 |
| --- | --- | --- |
| `Unsatisfied requirement` / 找不到内核 | 镜像路径、插件名称、系统类型、符号目录与 banner | 随机下载不同版本符号反复尝试 |
| Windows 信息插件失败 | dump 类型、镜像完整性、Windows 版本和网络可达的符号缓存 | 把失败当作镜像被篡改的证据 |
| Linux 插件为空 | `vmlinux`/DWARF、ISF、内核版本、采集格式与对象回收 | 因空输出断言“没有进程/连接” |
| macOS 插件异常 | 目标版本/架构、ISF、当前插件维护状态 | 关闭系统安全机制以强制采集 |
| CSV 与终端结果不一致 | renderer、列转义、筛选条件和工具版本 | 只保留结构化摘要、删除完整文本输出 |

## 9. 三端完成任务

- [ ] 对公开 Windows 镜像完成信息、进程树、命令行、模块、VAD、网络与异常内存区域的报告。
- [ ] 对自建 Debian AVML/LiME 镜像完成 banner/符号验证、进程、文件、网络与 VMA 的报告。
- [ ] 对公开 macOS 镜像完成符号来源、进程树、接口和命令历史的报告，并记录插件限制。
- [ ] 为每份报告附上镜像 SHA-256、Volatility 3 版本、命令、完整输出路径、符号来源与至少一种独立验证证据。

