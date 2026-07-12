# Noriben 实战手册

Noriben 是基于 Python 的 Procmon 自动化与报告工具：它负责启动/停止 Procmon、导出事件并按规则生成可读摘要；它不是内存采集器、沙箱替代品或结论引擎。所有动态实验仅在断网/隔离 Win11 虚拟机中对无害测试程序、公开教学样本或明确授权材料执行。

官方项目：[Rurik/Noriben](https://github.com/Rurik/Noriben)。项目当前 release、参数与配置格式可能更新，执行前始终以本地 `python Noriben.py --help` 和项目 release 说明为准。


Noriben/
├── images/                     # 存放项目相关图片
├── LICENSE                     # 项目许可文件
├── Noriben.config              # 项目配置文件
├── Noriben.py                  # 项目主要Python脚本
├── NoribenRead.py              # 用于读取和分析结果的Python脚本
├── NoribenSandbox.bat          # Windows系统下启动沙箱的批处理文件
├── NoribenSandbox.py           # Python脚本，用于自动化执行Noriben
├── NoribenSandbox.sh           # Linux系统下启动沙箱的脚本
├── ProcmonConfiguration.pmc    # Sysinternals Procmon的过滤配置文件
├── README.md                   # 项目说明文件
└── postexec.txt                # 执行后脚本文

## 获取与安装

1. 从官方 release 或已审计的源码归档获取 Noriben，保存 release 标签/Git commit、ZIP 哈希和许可证。
2. 解压到 `C:\Lab\Tools\Noriben`；从 Microsoft Sysinternals 获取经验证的 `Procmon.exe` 或 `Procmon64.exe`，并保留其版本与哈希。
3. 使用独立 Python 环境，避免污染系统 Python：

```powershell
cd C:\Lab\Tools\Noriben
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
python --version
python Noriben.py --help
```

4. 复制 `Noriben.config` 和 `ProcmonConfiguration.pmc` 到案例目录；不要直接修改唯一的原始配置。记录配置副本 SHA-256、Procmon 路径、Python 版本和 Noriben 版本。

> 运行 Noriben 和 Procmon 通常需要管理员权限。若受限环境不允许管理员权限或 Procmon 驱动加载，应记录限制，不要通过降低 Win11 安全配置来绕过。

### Procmon 路径排错

Noriben 2.0.4 按以下顺序查找配置项 `procmon` 指定的文件：配置中的直接路径、当前 `PATH`、`Noriben.py` 所在目录。出现 `Unable to find procmon.exe` 时，优先使用以下任一方式：

```powershell
# 方式一：将官方 Procmon.exe 放到 Noriben.py 同目录
Test-Path C:\tools\Noribe\Procmon.exe

# 方式二：在 Noriben.config 的 [Noriben] 段指定绝对路径
# procmon = C:\tools\Sysinternals\Procmon.exe

# 方式三：仅为当前 PowerShell 会话补充 PATH
$env:Path += ';C:\tools\Sysinternals'
where.exe procmon.exe
```

首选方式二：绝对路径可随案例配置副本一起归档。`ProcmonConfiguration.PMC` 被找到只说明过滤配置可用，不代表 `Procmon.exe` 已被找到。Python 3.14 的 `codecs.open()` 弃用警告不是该错误的原因；如果后续出现兼容性异常，改用隔离的 Python 3.12/3.13 环境并记录版本。

## 目录与证据命名

```text
C:\Lab\Evidence\LAB-001\
  00-环境元数据\        # Win11/Procmon/Noriben/Python 版本、哈希、时区
  01-配置\              # Noriben.config、PMC、白名单、YARA 规则副本
  02-Noriben-原始输出\  # PML、CSV、控制台日志
  03-Noriben-报告\      # TXT/CSV 摘要与人工标注
  04-关联证据\          # PCAP、内存镜像、Volatility 输出
```

文件名统一使用 `案例编号_UTC时间_主机_工具_类型`。例如：`LAB-001_20260711T090000Z_WIN11_procmon.pml`。原始 PML、导出 CSV 和报告都要计算 SHA-256；不可只保留 Noriben 的文本摘要。

## 执行前检查

- [ ] Win11 与 Ubuntu 仅位于内部/仅主机网络，无 NAT、桥接、共享剪贴板、共享目录或默认出网路由。
- [ ] 已还原 `win11-clean` 和 `ubuntu-clean` 快照，记录快照编号与时间。
- [ ] Procmon 可正常启动；用无害程序确认可以开始/停止捕获并保存 PML。
- [ ] `Noriben.config`、PMC、白名单和可选 YARA 规则均已复制到案例目录并记录哈希。
- [ ] 输出目录空间充足；PCAP、内存采集工具和 Volatility 3 已准备但尚未混入原始输出目录。
- [ ] 已明确本次问题：要观察进程树、文件/注册表变化、DNS/HTTP 行为还是内存采集前后的对象差异。

## 基础运行模式

### 模式 A：手动交互观察（默认推荐）

适用于需要在 Win11 中手动操作无害测试程序、观察窗口或同时启动 Wireshark/System Informer 的实验。

1. 在管理员 PowerShell 中激活虚拟环境并进入 Noriben 目录。
2. 指定本次输出目录，先运行帮助确认参数：

```powershell
python Noriben.py --help
python Noriben.py --output C:\Lab\Evidence\LAB-001\02-Noriben-原始输出 --headless
```

3. Noriben 启动 Procmon 后，再手动启动无害测试程序；同时记录 PID、开始时间与实验动作。
4. 关键动作完成后在 Noriben 控制台使用 `Ctrl+C` 结束采集。确认 PML、CSV、报告和控制台输出均写入案例目录。
5. 停止 Wireshark/服务端工具，记录结束时间，再开始人工审阅。

`--headless` 仅避免在虚拟机上自动打开结果；它不影响原始输出保留。

### 模式 B：固定时长采集

适用于可预期、无害且无需人工交互的演示程序。`-t`/`--timeout` 的秒数应与实验记录一致：

```powershell
python Noriben.py -t 60 --output C:\Lab\Evidence\LAB-001\02-Noriben-原始输出 --headless
```

采集窗口内手动启动测试程序，或在另有明确授权的自动化实验中使用项目支持的执行参数。仓库默认不使用 `--cmd` 自动执行未知文件；需要自动化时，先以无害测试程序完成一轮快照、输出和回滚验证。

### 模式 C：离线重新分析已有证据

用于调整过滤规则、修正报告或复核历史案例，不重新运行任何程序：

```powershell
python Noriben.py -p C:\Lab\Evidence\LAB-001\02-Noriben-原始输出\capture.pml --output C:\Lab\Evidence\LAB-001\03-Noriben-报告 --headless
python Noriben.py -c C:\Lab\Evidence\LAB-001\02-Noriben-原始输出\capture.csv --output C:\Lab\Evidence\LAB-001\03-Noriben-报告 --headless
```

每次重新分析都要保留使用的配置副本、命令、输入 PML/CSV 哈希和新报告，不能覆盖历史报告。

## 配置与过滤规则

Noriben 包含用于降低系统噪声的白名单与配置；它们决定哪些 Procmon 事件会出现在摘要中。正确做法是先保留默认配置，再基于案例做最小、可回滚的调整。

1. 复制默认 `Noriben.config` 到 `01-配置`，以案例编号命名。
2. 如需 Procmon 过滤器，复制默认 PMC；使用 `-f <PMC 路径>` 指定案例副本，例如：

```powershell
python Noriben.py -f C:\Lab\Evidence\LAB-001\01-配置\LAB-001.pmc --output C:\Lab\Evidence\LAB-001\02-Noriben-原始输出 --headless
```

3. 只添加明确、可解释的降噪规则，例如排除已验证的实验前后台噪声；不要用宽泛路径、进程名或网络过滤掩盖未知行为。
4. 对每一条新增过滤规则记录“原因、作者、时间、影响范围”；重新分析同一 PML，比较过滤前后报告差异。
5. `--generalize` 会将绝对路径替换为环境变量形式，便于报告归纳；保留原始 PML/CSV，以便恢复原始路径。

可选的 `--yara <规则目录>` 适合对**新建文件**进行授权规则扫描。规则必须作为案例证据副本保存，命中仅是待核查线索，不直接等同恶意结论。

## 报告判读方法

Noriben 报告通常按进程、文件、注册表、网络等事件归纳，具体栏目以当前版本输出为准。分析时按下面顺序进行：

1. **进程身份**：在报告中确定 PID、父进程、命令行和首次出现时间；回查原始 PML 的 Process Create 事件。
2. **文件与模块**：分开阅读文件创建/写入、映像加载和临时文件。路径可疑不代表加载或执行，需要 Procmon 操作类型与 System Informer/Volatility 模块信息支持。
3. **注册表**：区分读取、查询、创建与写入；把变化与 Regshot 前后快照交叉验证。
4. **网络线索**：将域名、IP、端口和时间映射到 Wireshark、FakeDNS/Apache/INetSim 日志。Noriben/Procmon 网络线索不能替代完整 PCAP。
5. **白名单影响**：摘要未出现的事件先检查配置和 PML，不能据此认定行为不存在。

## 与内存取证的联合流程

| Noriben 线索 | 运行时/外部复核 | 镜像侧复核 | 结论边界 |
| --- | --- | --- | --- |
| PID、父进程、命令行 | System Informer / Process Explorer | `windows.pslist`、`windows.pstree`、`windows.cmdline` | PID 会复用，必须结合时间与对象地址 |
| DLL/映像路径 | Process Explorer 模块页 | `windows.dlllist`、`windows.vadinfo` | 文件路径、模块加载和内存映射不是同一概念 |
| 文件/注册表写入 | PML、Regshot | 进程、句柄、内存中的 hive 表示 | 镜像不一定保留已关闭句柄或历史写入 |
| DNS/HTTP 线索 | Wireshark、FakeDNS、Apache/INetSim | `windows.netscan` 与进程对象 | 连接可能在采集时已关闭/回收 |
| 可疑内存线索 | System Informer 线程/内存区域 | `windows.malfind`、VAD、线程与字节上下文 | 单一插件或规则命中不足以下结论 |

内存采集时机应写入 Noriben 时间线：至少记录“Noriben 开始、测试程序启动、关键行为、内存采集开始/结束、Noriben 停止”六个时间点。

## 常见问题与排查

| 现象 | 优先检查 | 处理原则 |
| --- | --- | --- |
| 找不到 Procmon | Noriben/Procmon 同目录或配置中的路径、文件名、管理员权限 | 修正路径并用无害程序重测，不下载未知替代二进制 |
| 没有 PML/报告 | 输出目录权限、磁盘空间、Procmon 是否已启动、控制台报错 | 保留报错和环境信息；不要假设“无行为” |
| 报告事件太少 | PMC/白名单/过滤规则、采集起止时间 | 先离线重分析同一 PML，再最小化调整规则 |
| 报告噪声太大 | 是否保留默认白名单、是否在干净快照运行 | 不用宽泛排除规则；按已验证噪声逐条处理 |
| 时间与 PCAP 不一致 | Win11/Ubuntu 时区、NTP、采集开始/结束记录 | 统一到 UTC，在报告中保留原始时区 |
| YARA/哈希功能失败 | 规则/白名单路径、依赖、输入权限 | 把附加扫描视为可选，核心 PML 不受其失败影响 |

## 实战场景：DNS → HTTP → 内存镜像

**目标**：在无害测试程序中形成一次受控 DNS 查询与 HTTP 请求，并把 Noriben 时间线连接到网络和内存证据。

1. 还原 Win11/Ubuntu 快照；Ubuntu 启动 FakeDNS 与 Apache，保存规则/页面哈希。
2. Win11 启动 Wireshark 和 Noriben（模式 A）；记录 Noriben 开始时间。
3. 手动运行无害测试程序，记录 PID、DNS/HTTP 发生时间和目标域名。
4. 在连接仍存在的窗口采集内存；立即计算镜像 SHA-256。
5. 停止 Noriben、Wireshark 和 Ubuntu 服务，归档 PML、CSV、Noriben 报告、PCAP、DNS/HTTP 日志。
6. 以 PID、五元组、域名、时间和内存对象地址完成三方关联；记录连接未出现在镜像中的可能原因。

## 完成清单

- [ ] Noriben、Procmon、Python、配置、PMC 和可选规则均有版本/哈希。
- [ ] 原始 PML、导出 CSV、报告、命令、控制台输出和配置副本完整保留。
- [ ] 每条摘要结论可回到原始 PML 或另一个独立来源。
- [ ] 网络线索与 PCAP/服务端日志对齐；内存结论与 Volatility 原始输出对齐。
- [ ] 实验结束后证据已导出、虚拟机已关闭并还原干净快照。
