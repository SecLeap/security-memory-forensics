# Velocidex WinPmem 实战手册

> 适用范围：对已获得授权的 Windows 终端执行一次性物理内存采集，并将 RAW 镜像交付给离线分析机。WinPmem 会加载内核驱动，采集行为本身会改变目标系统状态；目标是最小化、记录并说明这种影响，而不是宣称“零影响”。

[Velocidex/WinPmem](https://github.com/Velocidex/WinPmem) 的 `winpmem_mini_x86.exe` 与 `winpmem_mini_x64.exe` 是自包含的 RAW 镜像采集程序，会自动加载相应驱动，采集结束后自动卸载。官方仓库目前公开说明的支持范围为 Windows 7–10，且最新公开 release 较早；在 Windows 11 或任何新内核上使用前，必须先在**同版本、同补丁级别、同安全策略**的实验机完成兼容性与完整性验证。本手册不把历史兼容说明扩展为 Win11 支持承诺。

## 获取、校验与采集包准备

### 1. 仅使用官方发布物

1. 从 [官方 Releases](https://github.com/Velocidex/WinPmem/releases) 获取发布包，将原始文件保存到受控介质的 `Tools\WinPmem\` 目录。
2. 记录下载 URL、发布标签、文件名、许可证、下载时间、发布包 SHA-256 与可执行文件 SHA-256；不要使用第三方重打包、未签名替代版本或截图中的未知采集器。
3. 在隔离实验机上解压并核验，采集现场只携带已验证的最小工具集和文档模板。

```powershell
Get-FileHash 'E:\Tools\WinPmem\<发布包或可执行文件>' -Algorithm SHA256
Get-AuthenticodeSignature 'E:\Tools\WinPmem\winpmem_mini_x64.exe' |
  Format-List Status,StatusMessage,SignerCertificate
```

数字签名状态、发布包哈希和来源应一同记录；签名信息不能替代文件哈希或来源校验。

### 2. 采集前实验验证

对计划采集的每一类目标（特别是 Windows 11）建立一次验证记录：

- 系统版本、内核版本、架构、补丁级别和内存容量；
- 驱动加载是否成功、是否生成 RAW 镜像、镜像大小是否与内存规模合理对应；
- 用 Volatility 3 与 MemProcFS 是否能解析基本进程/系统信息；
- 采集耗时、终端输出、EDR/防病毒提示及已批准的处置方式；
- 工具版本、SHA-256、采集命令与输出文件哈希。

没有通过同环境验证时，不要在关键现场临时关闭安全功能、启用测试签名模式或替换驱动；改用已批准且已验证的采集方案，并记录原因。

## 采集前检查清单

### 1. 授权、时间与输出介质

1. 确认授权范围、目标标识、操作者、见证人（如要求）、采集目的和允许的停机窗口。
2. 记录目标本地时间、时区、时间源、主机名、已登录用户、网络状态、系统版本、架构、物理内存大小和可用磁盘空间。
3. 准备受控输出介质或加密本地证据卷，空闲空间至少覆盖预期镜像及校验/副本开销；输出目录须在开始前创建并写入权限经过验证。
4. 不将镜像直接写到网络共享、个人同步盘、临时目录或系统盘；若组织流程必须使用网络传输，应在采集完成、哈希固定后作为独立的证据转移步骤记录。

```powershell
$case = 'CASE-20260711-001'
$dest = "E:\Evidence\$case\01-内存镜像"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture,LastBootUpTime
Get-CimInstance Win32_ComputerSystem | Select-Object Name,TotalPhysicalMemory
Get-Volume -DriveLetter E | Select-Object DriveLetter,SizeRemaining,Size,FileSystem
Get-Date -Format o
```

这些命令也是对活系统的额外操作；应先于采集执行一次、记录输出后停止无关操作。不要在采集前运行清理、杀进程、重启、全盘扫描或样本执行。

### 2. 采集命名与元数据

建议命名：`<案例号>_<主机标识>_<UTC时间>_winpmem.raw`，例如 `CASE-20260711-001_WS-01_20260711T031500Z_winpmem.raw`。

最小元数据字段：

| 字段 | 说明 |
| --- | --- |
| 案例与目标标识 | 与授权和证据编号一致 |
| 工具信息 | 文件名、版本/发布标签、SHA-256、来源、签名状态 |
| 目标信息 | 主机名、OS/构建号、架构、内存容量、启动时间 |
| 采集信息 | 操作者、开始/结束 UTC、完整命令、输出介质、退出状态/控制台输出 |
| 镜像信息 | 文件名、大小、SHA-256、后续副本及保管位置 |
| 异常 | 驱动/EDR 提示、失败、重试及对证据的潜在影响 |

## 使用方法

### 1. 确认架构与最小验证

选择与目标 OS 架构匹配的 `winpmem_mini_x86.exe` 或 `winpmem_mini_x64.exe`。两者都包含对应的驱动，但仍应按目标系统架构明确选择并记录。

```powershell
[Environment]::Is64BitOperatingSystem
& 'E:\Tools\WinPmem\winpmem_mini_x64.exe'
```

不带参数运行会打印官方简要用法。此步骤只用于确认当前采集包可启动；不要把输出文件写入目标默认目录。

### 2. 标准 RAW 采集

使用固定的绝对输出路径。执行前再次确认盘符不是系统盘、路径指向本案例、文件名没有覆盖旧证据。

```powershell
$tool = 'E:\Tools\WinPmem\winpmem_mini_x64.exe'
$image = 'E:\Evidence\CASE-20260711-001\01-内存镜像\CASE-20260711-001_WS-01_20260711T031500Z_winpmem.raw'

& $tool $image
$exitCode = $LASTEXITCODE
"ExitCode=$exitCode; EndUtc=$((Get-Date).ToUniversalTime().ToString('o'))" |
  Tee-Object -FilePath 'E:\Evidence\CASE-20260711-001\01-内存镜像\winpmem-acquisition.log' -Append
```

官方示例表明 mini 版本以 RAW 格式输出，默认方法完成采集。采集过程中不要操作目标、切换用户、插拔输出介质或运行其他分析工具。WinPmem 驱动应在完成后自动卸载；保留控制台输出和退出状态，不要为“清理痕迹”额外执行驱动卸载、日志清理或重启操作。

### 3. 备选读取方法：仅在预先验证后使用

官方 README 提供 `winpmem.exe -1 myimage.raw` 以指定 MmMapIoSpace 读取方法。此类方法选择只能依据同环境实验验证或既定采集 SOP；不可在现场以反复尝试方式覆盖或比较多个镜像。

```powershell
# 仅适用于已验证的完整 WinPmem 版本和既定 SOP；不可与现场临时试错混用。
& 'E:\Tools\WinPmem\winpmem.exe' -1 'E:\Evidence\CASE-20260711-001\01-内存镜像\CASE-20260711-001_WS-01_method1.raw'
```

若标准方法失败，记录错误、时间和目标状态，停止并遵循获批的替代采集方案。不要启用仓库描述为实验性的写入支持；官方签名二进制默认禁用写入能力，本手册禁止使用任何 `-w`、测试签名或自编译写驱动流程。

## 采集后固定与验证

### 1. 即时哈希与只读保管

采集完成后立即计算 SHA-256；在需要时再计算 SHA-1/MD5 仅为与既有系统兼容，SHA-256 为主校验值。哈希完成前不得移动、压缩、上传或导入分析工具。

```powershell
$image = 'E:\Evidence\CASE-20260711-001\01-内存镜像\CASE-20260711-001_WS-01_20260711T031500Z_winpmem.raw'
Get-Item $image | Select-Object FullName,Length,CreationTimeUtc,LastWriteTimeUtc |
  Format-List | Tee-Object -FilePath 'E:\Evidence\CASE-20260711-001\01-内存镜像\image-metadata.txt'
Get-FileHash $image -Algorithm SHA256 |
  Tee-Object -FilePath 'E:\Evidence\CASE-20260711-001\01-内存镜像\image-sha256.txt'
```

建立至少一份受控副本，复制后在目标端和副本端分别计算 SHA-256 并比对。原始采集镜像保持只读；所有后续工具使用工作副本，转移、访问与校验结果进入证据保管记录。

### 2. 解析可用性检查

可用性检查不是深入分析，也不应修改镜像：

1. 在离线分析机对工作副本计算 SHA-256，并确认与采集端一致。
2. 按 [Volatility 3 实战手册](../02-Volatility3-实战手册.md) 运行基础信息/进程枚举，保存命令及完整输出。
3. 按 [MemProcFS 实战手册](32-MemProcFS.md) 以只读方式挂载工作副本，核对系统基本信息、进程数量和解析日志。
4. 若工具结果不同，先检查镜像哈希、OS 识别、符号、版本与插件范围；将差异保留为待解释事项，不覆盖原始结果。

完成标准：镜像哈希在采集端和分析端一致，至少一条独立解析路径能读取合理的系统/进程基本信息，且所有失败与限制均已记录。

## 场景化流程

### 场景一：受控 Win11 内存分析实验

1. 在 Win11 实验 VM 的关键行为时间点停止新的交互，记录时间和当前测试 PID。
2. 以已验证的 WinPmem 采集包将 RAW 镜像写至案例证据卷，立即计算 SHA-256。
3. 在隔离分析机上用 Volatility 3 和 MemProcFS 对同一工作副本分别获取进程、命令行、模块、VAD/内存映射与网络对象。
4. 仅对来源明确的导出物运行 PEStudio、DiE、FLOSS 或 capa；静态工具结果与内存对象的 PID、地址、时间关系一同记录。

### 场景二：采集失败或中断

1. 保留屏幕/控制台信息、退出码、事件时间、工具哈希和已产生文件大小；不要删除不完整文件。
2. 为未完成文件计算哈希并标注“未完成/不可作为完整 RAM 镜像”，与正常镜像分开存放。
3. 记录错误、目标状态变化和已尝试方法；未获明确授权不重复采集或切换到其他驱动/采集器。
4. 由既定 SOP 选择后续方案；后续镜像必须作为新的采集事件重新编号。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 工具无法启动或驱动无法加载 | 检查目标架构、工具哈希、签名状态、系统/安全策略与实验兼容性记录；不要关闭安全功能或启用测试签名来绕过 |
| 输出空间不足或写入失败 | 停止操作，保留未完成文件并计算哈希；更换经批准、容量充足的证据介质后按新采集事件执行 |
| 镜像大小异常 | 记录物理内存、文件大小、退出状态与时间；用独立解析工具检查，不要凭文件大小单独判定成功/失败 |
| 哈希在转移后不一致 | 立即停止分析，保留两端文件和计算记录，重新核验复制路径/介质；不要覆盖任何一端 |
| Volatility/MemProcFS 解析异常 | 先检查哈希、镜像完整性、工具版本、OS 架构/符号设置；保留错误与输出并选择已批准的独立复核方法 |
| 防病毒/EDR 告警 | 这是内核采集工具的常见运营风险；在实验验证阶段预先处理规则与批准，现场只记录并按流程处置，不私自建立永久排除项 |

## 实战检查清单

- [ ] 已具备明确授权、目标信息、时间记录与可用的受控输出介质。
- [ ] 已在同类系统（特别是 Win11 版本/补丁/策略）完成工具兼容性验证。
- [ ] 已记录 WinPmem 发布来源、版本、SHA-256、签名状态和完整命令。
- [ ] 输出路径为案例专属目录，未覆盖旧证据，也未写入网络共享/同步目录。
- [ ] 已立即计算并在转移后复核镜像 SHA-256；原始镜像已只读保管。
- [ ] 未使用 `-w`、测试签名、自编译写驱动、实时分析或未授权重试。
- [ ] 已用 Volatility 3 与 MemProcFS 对工作副本完成最小可用性互证。

## 官方资料

- [Velocidex/WinPmem 项目与使用示例](https://github.com/Velocidex/WinPmem)
- [WinPmem Releases](https://github.com/Velocidex/WinPmem/releases)
- [Volatility 3 实战手册](../02-Volatility3-实战手册.md)
- [MemProcFS 实战手册](32-MemProcFS.md)
