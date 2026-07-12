# MemProcFS 实战手册

> 适用范围：在隔离的 Windows 11 分析机上，以**只读离线方式**分析已完成哈希校验的内存镜像。MemProcFS 将物理内存及其解析结果呈现为虚拟文件系统，适合快速浏览、导出和结构化留档；它不替代原始内存镜像、采集记录或 Volatility 3 的独立复核。

[MemProcFS](https://github.com/ufrisk/MemProcFS) 支持镜像文件、实时内存和多种 API。本手册默认且仅覆盖**镜像文件离线挂载**。不在取证工作流中使用远程代理、FPGA、实时 `pmem` 设备或任何读写模式；这类方式会扩大授权、稳定性和证据完整性风险，需另行审批与专门采集方案。

## 获取与安装

### 1. 组件与校验

1. 从 [MemProcFS 官方 Releases](https://github.com/ufrisk/MemProcFS/releases) 获取 Windows 发布包，保留原始 ZIP 至 `C:\Lab\Installers\MemProcFS\`，解压至 `C:\Lab\Tools\MemProcFS\`。
2. Windows 挂载虚拟文件系统需要安装 [Dokany 2](https://github.com/dokan-dev/dokany/releases/latest)。Dokany 是系统级文件系统组件，只在专用分析 VM 安装；记录版本、安装包 SHA-256、来源和快照。
3. 分别计算 MemProcFS 发布包和 Dokany 安装包哈希，记录发布标签、许可证、下载 URL、下载时间和操作者。

```powershell
Get-FileHash 'C:\Lab\Installers\MemProcFS\<发布包>' -Algorithm SHA256
Get-FileHash 'C:\Lab\Installers\Dokany\<安装包>' -Algorithm SHA256
Set-Location 'C:\Lab\Tools\MemProcFS'
.\MemProcFS.exe -h
```

完成标准：帮助信息可显示，且分析 VM 已创建工具基线快照。首次启动前确认不包含实时 `-device pmem`、`-device fpga`、远程设备或写入相关参数。

### 2. 目录与网络边界

```text
C:\Lab\Cases\LAB-001\
├─ 00-原始镜像\          # 只读保存的 RAM 镜像与原始 SHA-256
├─ 01-伴随文件\          # 同时/近同时采集的 pagefile、swapfile（如有）
├─ 02-MemProcFS-导出\    # 从挂载盘复制出的 CSV、JSON、日志、Yara 结果
├─ 03-Volatility3-输出\
└─ 04-分析笔记\
```

首次启动可能触发符号服务器相关行为。离线或受控网络分析时使用 `-disable-symbolserver`，并在报告中说明符号下载被禁用及其对解析完整性的潜在影响。不要让未知样本或案例输出离开隔离环境。

## 镜像挂载与取证模式

### 1. 基础只读挂载

默认 Windows 挂载盘符为 `M:`；为避免冲突，案例中显式指定一个未使用的盘符。挂载前先验证镜像哈希，并将原始镜像目录设为只读。

```powershell
$case = 'LAB-001'
$image = 'C:\Lab\Cases\LAB-001\00-原始镜像\memory.raw'
$out = "C:\Lab\Cases\$case\02-MemProcFS-导出"
New-Item -ItemType Directory -Force -Path $out | Out-Null
Get-FileHash $image -Algorithm SHA256 | Tee-Object -FilePath "$out\$case-input-hash.txt"

Set-Location 'C:\Lab\Tools\MemProcFS'
.\MemProcFS.exe -device $image -mount M -disable-symbolserver -v
```

保持 MemProcFS 进程运行，另开 PowerShell 浏览 `M:\`。工作完成后通过正常关闭 MemProcFS 卸载，不要强制结束进程或直接拔除映射盘符。挂载盘是分析视图：只读取、复制输出到案例目录；不要在其上删除、改名或写入文件。

### 2. 可复现取证模式

对需要导出结构化结果的案例，在启动时启用取证模式。官方说明指出：对文件型镜像，在命令行启动取证模式后，同一 MemProcFS 版本下结果应可重现；不在启动时启用可能受到多线程和缓存排序影响。

```powershell
$log = "C:\Lab\Cases\LAB-001\02-MemProcFS-导出\LAB-001-memprocfs.log"
.\MemProcFS.exe -device $image -mount M -forensic 1 -disable-symbolserver `
  -logfile $log -loglevel f:4
```

`-forensic` 的模式值含义：`1` 仅内存 SQLite；`2` 临时 SQLite、退出后删除；`3` 临时 SQLite、退出后保留；`4` 保留已知 SQLite 数据库。对于首次人工分析，使用 `1` 并将完成后的 VFS 导出物复制到案例目录；若采用 `3/4`，必须记录数据库实际位置、哈希、保留策略和访问控制，避免不同案例复用同一数据库。

取证处理完成后，`forensic\csv`、`forensic\json`、`forensic\timeline`、`forensic\findevil`、`forensic\files`、`forensic\yara` 等目录会根据版本、输入和启用模块呈现相应结果。目录或文件不存在本身不是“未发现”的结论，应先查看日志和版本说明。

### 3. Pagefile 的使用条件

只有 pagefile/swapfile 与 RAM 镜像在同一时间或足够接近的时间采集、且能证明关联关系时，才允许加入。官方文档警告，使用不同时间点的旧页面文件会显著降低分析质量并引入错误数据。

```powershell
.\MemProcFS.exe -device $image -mount M -forensic 1 -disable-symbolserver `
  -pagefile0 'C:\Lab\Cases\LAB-001\01-伴随文件\pagefile.sys' `
  -pagefile1 'C:\Lab\Cases\LAB-001\01-伴随文件\swapfile.sys'
```

分别记录镜像和每个页面文件的 SHA-256、获取时间、来源、参数及是否确认为同一系统会话。缺少这些条件时，不要添加页面文件。

## 虚拟文件系统使用方法

### 1. 分层浏览与留档

从挂载根目录开始，先记录版本、状态、镜像识别和系统概览，再进入专题目录。根目录下常见分组包括：

| 分组 | 用途 | 取证使用方式 |
| --- | --- | --- |
| `sys\` | 系统、内存、网络、服务、驱动、对象等全局视图 | 快速形成系统范围对象清单，与 Volatility 输出交叉检查 |
| `registry\` | 注册表视图 | 定位持久化或配置线索，保留路径和值的导出依据 |
| 进程虚拟目录 | 各进程的模块、内存图、线程、句柄、文件和虚拟内存等 | 以 PID、创建时间和命令行先锁定进程，再浏览对应子项 |
| `forensic\` | 取证模式生成的 CSV、JSON、时间线、文件恢复、Yara/FindEvil 等 | 复制原始导出物至案例目录，连同工具版本和命令保存 |
| `misc\` | 搜索、视图、事件日志、地址转换等辅助功能 | 仅用于定位与复核，关键结论回到原始对象/字节 |
| `vm\` | 识别出的虚拟机相关视图（若启用） | 不在默认流程启用，避免无关资源消耗和解释复杂度 |

实际可见路径随 OS、镜像、MemProcFS 版本和启用模块变化。以挂载盘根目录和本次版本的 [官方文件系统说明](https://github.com/ufrisk/MemProcFS/wiki) 为准，不把缺失目录视为否定证据。

### 2. 复制原始结果

不要直接在挂载盘上编辑 CSV/JSON。将所需输出复制到案例目录后再分析，并为复制结果计算哈希。

```powershell
Copy-Item 'M:\forensic\csv\*' "$out\csv" -Recurse -Force
Copy-Item 'M:\forensic\json\*' "$out\json" -Recurse -Force
Copy-Item 'M:\forensic\timeline\*' "$out\timeline" -Recurse -Force
Get-ChildItem $out -Recurse -File | Get-FileHash -Algorithm SHA256 |
  Export-Csv "$out\LAB-001-export-hashes.csv" -NoTypeInformation -Encoding utf8
```

若某目录不存在，勿将其作为错误强行创建在 `M:`；在案例导出目录记录“未生成”、日志位置和所用参数即可。

### 3. Yara 与 FindEvil 的使用边界

可通过 `-forensic-yara-rules <规则文件>` 在取证模式中扫描。只使用版本固定、经审核的规则；将规则文件、依赖文件和 SHA-256 与命令一同保存。规则命中表示某内存/文件对象满足规则条件，必须回到命中地址、对象来源、原始字节和进程/VAD 上下文复核。

```powershell
$rules = 'C:\Lab\Rules\Yara\windows-memory-index.yar'
Get-FileHash $rules -Algorithm SHA256 | Tee-Object -FilePath "$out\LAB-001-yara-rule-hash.txt"
.\MemProcFS.exe -device $image -mount M -forensic 1 -disable-symbolserver `
  -forensic-yara-rules $rules
```

FindEvil 或内置 Yara 提示同样是分流线索。不要仅凭命中名称判断恶意，也不要自动接受额外的第三方规则许可；记录规则来源、版本和许可。

## 与 Volatility 3 的联合分析

### 场景一：进程、网络与 VAD 互证

1. 在 MemProcFS 中从系统/进程视图记录 PID、名称、创建时间、命令行、模块、线程、内存映射和网络对象。
2. 在 [Volatility 3 实战手册](../02-Volatility3-实战手册.md) 中对同一镜像运行进程、命令行、模块、VAD、线程和网络相关插件，保存命令与完整输出。
3. 以 PID、内核对象地址（如可获得）、创建时间、映像路径和地址范围对齐，而不是只按进程名匹配。
4. 结果不一致时优先检查工具版本、符号设置、镜像完整性、系统版本、页面文件条件和解析范围；将差异写入报告，而非选择单一“更符合预期”的输出。

### 场景二：从对象到字节的复核

1. MemProcFS 快速定位候选进程、文件恢复项、VAD 或 Yara 命中后，保存其路径、PID、地址、偏移和对应导出物哈希。
2. 使用 HxD、PEStudio、DiE、FLOSS 或 capa 对**复制出的工作副本**进行静态分析；不要在挂载盘上修改对象。
3. 回到 Volatility 3 验证对象的进程关系、内存保护、线程入口和模块映射，再将静态线索与内存上下文关联。

完成标准：每个结论都能回溯到“镜像哈希 → MemProcFS 命令/版本 → VFS 路径或导出文件哈希 → Volatility 输出/原始字节”。

## Python API（只读、可审计的小规模查询）

MemProcFS 提供 Python API，既可读虚拟文件系统，也可读物理或进程虚拟内存。自动化仅针对副本和已知地址范围；脚本应把输入镜像哈希、启动参数、读取地址/长度和输出哈希写入日志。不要在 API 中调用任何写入方法，也不要把 API 用于实时目标。

官方示例的最小初始化模式如下，需以当前发行版 API 文档为准：

```python
import memprocfs

vmm = memprocfs.Vmm([
    '-device', r'C:\Lab\Cases\LAB-001\00-原始镜像\memory.raw',
    '-disable-symbolserver'
])
print(vmm.vfs.list('/sys/services'))
```

分析结束后，保留脚本源码、依赖版本、命令行和输出文件；对于需读取地址范围的任务，优先使用 VFS 导出物或 Volatility 确认地址后再读取。

## 常见问题与排错

| 现象 | 可能原因与处理 |
| --- | --- |
| 无法挂载盘符 | 检查 Dokany 2 是否已在分析 VM 安装、盘符是否被占用及 MemProcFS 日志；不要改用来源不明的驱动 |
| 取证目录未出现或内容不完整 | 确认启动参数含 `-forensic`，等待处理完成，查看日志、工具版本和镜像识别状态；不要把“未出现”当作“未发现” |
| 结果跨次运行不同 | 固定 MemProcFS/规则/符号设置，在启动时使用 `-forensic`，比较镜像与页面文件哈希、参数和导出时机 |
| 解析受限或符号相关信息缺失 | 检查 OS/架构识别和 `-disable-symbolserver` 设置；保持网络边界优先，并将限制写入报告 |
| 加入 pagefile 后结果异常 | 核实 pagefile 与镜像是否同一/近同时会话；无法证明时移除页面文件并重新记录分析 |
| Yara/FindEvil 命中 | 保存规则哈希、命中路径/地址、原始字节和进程上下文；用 Volatility 与静态工具复核 |

## 实战检查清单

- [ ] 已保存原始镜像及 SHA-256，分析使用只读副本或只读目录。
- [ ] 已记录 MemProcFS、Dokany、规则、符号设置和全部启动参数。
- [ ] 已采用离线镜像 `-device <image>`，未使用实时、远程、FPGA 或写入模式。
- [ ] 已在启动时启用并记录 `-forensic` 模式，保留日志和原始 VFS 导出物哈希。
- [ ] 页面文件仅在可证明近同时采集时加入，且已记录关联依据。
- [ ] Yara/FindEvil 和任何对象线索均已用原始字节、进程/VAD 上下文和 Volatility 3 复核。

## 官方资料

- [MemProcFS 项目、下载与基础示例](https://github.com/ufrisk/MemProcFS)
- [命令行选项与取证模式](https://github.com/ufrisk/MemProcFS/wiki/_CommandLine)
- [虚拟文件系统/API 总览](https://github.com/ufrisk/MemProcFS/wiki/API_C)
- [取证 JSON 输出说明](https://github.com/ufrisk/MemProcFS/wiki/FS_Forensic_JSON)
