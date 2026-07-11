# FLARE-FLOSS 实战手册

> 适用范围：隔离的 Windows 11 分析虚拟机、已获授权的样本工作副本，以及从内存镜像恢复出的明确候选二进制/原始代码区域。FLOSS 是**静态字符串提取与解码**工具，不执行待分析文件；恢复出的字符串是线索，不等于该字符串在本次运行中被使用。

[FLARE Obfuscated String Solver（FLOSS）](https://github.com/mandiant/flare-floss) 在常规 ASCII/UTF-16LE 静态字符串之外，还可提取栈字符串、tight strings 和函数中解码出的字符串；对 Go、Rust 还可提取便于人工阅读的语言特定字符串。它适合替代初筛阶段的普通 `strings.exe`，但不能替代动态行为或内存上下文验证。

## 获取与安装

### 1. 首选独立可执行文件

对于本仓库的手工分析场景，优先从 [官方 Releases](https://github.com/mandiant/flare-floss/releases) 下载 Windows 独立可执行文件。官方说明指出，独立版包含运行 FLOSS 所需的解释器和资源，无需安装 Python。

1. 将发布包原件保存至 `C:\Lab\Installers\FLOSS\`，解压/放置至 `C:\Lab\Tools\FLOSS\`。
2. 在案例或工具安装记录中保留下载 URL、发布标签、文件名、SHA-256、下载时间和许可证信息。
3. 不使用第三方打包版、来源不明的 `floss.exe`，也不要以下载到的样本作为安装包完整性测试对象。

```powershell
Get-FileHash 'C:\Lab\Installers\FLOSS\<发布包或 floss.exe>' -Algorithm SHA256
Get-ChildItem 'C:\Lab\Tools\FLOSS' -File
Set-Location 'C:\Lab\Tools\FLOSS'
.\floss.exe -h
.\floss.exe -H
```

`-h` 显示常用参数，`-H` 显示全部支持参数。完成标准：命令可显示帮助信息，且已记录工具版本/发布标签和二进制 SHA-256。

### 2. Python 包方式（仅自动化或二次开发）

官方将 Python 包方式定位为作为库或自动化系统的一部分使用，并要求 Python 3.10 及以上。不要将其与现有其他工具的 Python 环境混装；创建独立虚拟环境并固定版本。

```powershell
py -3.12 -m venv C:\Lab\venvs\floss
C:\Lab\venvs\floss\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install flare-floss
floss -h
```

若分析机没有 Python 3.12，可使用满足官方最低要求的已验证版本。手工分析优先回到独立版；从源码安装、修改解码逻辑或构建发布包属于开发活动，应与案例分析环境分离。

## 证据准备与输出约定

```text
C:\Lab\Cases\LAB-001\
├─ 00-原始文件\
├─ 01-工作副本\
├─ 02-静态识别\FLOSS\
│  ├─ LAB-001_<短哈希>_floss-default.txt
│  ├─ LAB-001_<短哈希>_floss-decoded.json
│  └─ LAB-001_<短哈希>_floss-commands.txt
└─ 04-内存镜像与导出物\
```

1. 对原始文件、FLOSS 输入副本和输出文件分别记录 SHA-256；输入对象必须可追溯到磁盘原件或内存导出来源。
2. 在 `floss-commands.txt` 保存每次执行命令、工具版本、开始/结束时间、输入哈希和退出状态。
3. 字符串须保留类型（static、stack、tight、decoded）、偏移/函数位置（若使用详细模式）及原始输出行；不要只摘取“看起来可疑”的字符串。
4. 任何 URL、IP、路径、命令、凭据样式文本或解码结果均按候选线索处理；不访问、不执行、不对外提交样本或输出。

## 使用方法

### 1. 默认完整初筛

默认模式提取静态 ASCII/UTF-16LE、stack、tight 和 decoded 字符串；默认最小长度为 4。对每个工作副本，先完整运行一次并保存原始文本输出。

```powershell
$case = 'LAB-001'
$sample = 'C:\Lab\Cases\LAB-001\01-工作副本\candidate.exe'
$outDir = "C:\Lab\Cases\$case\02-静态识别\FLOSS"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

Set-Location 'C:\Lab\Tools\FLOSS'
.\floss.exe -- $sample | Tee-Object -FilePath "$outDir\$case-floss-default.txt"
Get-FileHash $sample -Algorithm SHA256 | Tee-Object -FilePath "$outDir\$case-floss-commands.txt" -Append
```

`--` 表示后续内容为输入文件路径，尤其适用于路径以连字符开头或前面已有多个选项的情况。FLOSS 输出中不同类型的字符串应分开阅读：static 只能说明字节存在；decoded/stack/tight 表示工具按静态分析推导出的可读结果，仍需复核其函数位置和运行时证据。

### 2. 聚焦字符串类型

先保留完整结果，再按问题缩小范围，避免在一开始就遗漏线索。

```powershell
# 只看函数中恢复的解码字符串
.\floss.exe --only decoded -- $sample | Tee-Object -FilePath "$outDir\$case-floss-decoded.txt"

# 只看栈构造的两类字符串
.\floss.exe --only stack tight -- $sample | Tee-Object -FilePath "$outDir\$case-floss-stack-tight.txt"

# 静态字符串已由其他工具完整留档时，可跳过静态部分
.\floss.exe --no static -- $sample | Tee-Object -FilePath "$outDir\$case-floss-no-static.txt"

# 长字符串优先视图：降低随机数据伪字符串噪声，但不能替代默认输出
.\floss.exe -n 10 -- $sample | Tee-Object -FilePath "$outDir\$case-floss-min10.txt"
```

`--only` 与 `--no` 不能同时使用。提高 `-n/--minimum-length` 会减少随机字节噪声，也可能遗漏短而关键的字符串；因此它只是辅助视图，不是证据原件的替代。

### 3. JSON 与详细输出

`-j/--json` 将结构化结果输出至标准输出，适合保存为可复读的原始结果；`-l/--load` 可重新查看先前 JSON，而无需重跑分析。`-v` 能附加函数偏移和编码等详细信息，适合把字符串定位回静态和内存上下文。

```powershell
.\floss.exe -j -- $sample | Out-File -FilePath "$outDir\$case-floss.json" -Encoding utf8
.\floss.exe -l "$outDir\$case-floss.json"
.\floss.exe -v --only decoded -- $sample | Tee-Object -FilePath "$outDir\$case-floss-decoded-verbose.txt"
```

JSON 文件应与产生它的工具版本、输入哈希和命令一同保存。后续脚本只能读取副本，不能覆盖 JSON 原始输出。

### 4. 原始 shellcode/裸二进制

对来源、架构和导出边界已明确的裸代码候选物，FLOSS 可用 `-f/--format` 指明 `sc32` 或 `sc64`。不要仅因为某块 VAD 可写可执行就随意导出、猜测格式或把结果标为 shellcode。

```powershell
.\floss.exe -f sc64 -- 'C:\Lab\Cases\LAB-001\04-内存镜像与导出物\pid-1234-vad-00007ff6.bin' `
  | Tee-Object -FilePath "$outDir\LAB-001-floss-sc64.txt"
```

记录：完整镜像哈希、Volatility 导出命令、PID、VAD 起止地址、页保护、线程起始地址、导出文件哈希和选择 `sc32/sc64` 的依据。格式选择不确定时，分别记录“未确定”，不要把失败结果解释为无恶意内容。

## 结果解读与复核

| FLOSS 结果 | 可以说明什么 | 不能说明什么 | 下一步 |
| --- | --- | --- | --- |
| static URL、路径、域名 | 文件字节中存在相应可读文本 | 该地址被连接或该路径被访问 | HxD/PEStudio 定位；与 PCAP、DNS/HTTP、Procmon 对齐 |
| stack/tight 字符串 | 代码中有在栈上构造/修改字符串的静态迹象 | 字符串已在本次运行中出现 | 用 `-v` 记录函数位置；在 Ghidra/x64dbg 与内存证据复核 |
| decoded 字符串 | FLOSS 推导出某函数可能产生的字符串 | 解码函数已被调用、字符串为真实 C2 或命令 | 查看函数逻辑、交叉查网络/文件/注册表和内存时间线 |
| Go/Rust 语言特定字符串 | 可能更准确呈现对应编译器的字符串布局 | 仅凭字符串确认语言、家族或意图 | 用 DiE、PEStudio、导入表和二进制结构交叉判断 |
| 没有 decoded 输出 | 当前静态分析未恢复解码字符串 | 样本没有隐藏字符串或一定无害 | 检查格式、壳/加密、截断、入口点及动态/内存证据 |

## 与内存取证的联合使用

### 场景一：磁盘样本—行为—内存闭环

1. 测试前：对工作副本运行 FLOSS 默认模式、PEStudio 与 DiE，保存哈希和完整输出。
2. 测试中：用 Noriben/Procmon 记录进程、文件和注册表事件；以 Wireshark 或 FakeNet-NG 保存受控网络证据。
3. 关键时刻采集全量内存镜像，按 [Volatility 3 实战手册](../02-Volatility3-实战手册.md) 记录 PID、命令行、VAD、模块、线程和网络对象。
4. 将 FLOSS 中的域名/路径/命令候选项逐一关联到 PML、PCAP、服务日志或 Volatility 对象；报告中分别写明“静态字符串线索”和“运行时已验证事实”。

### 场景二：从内存导出物恢复线索

1. 保留全量镜像和 Volatility 原始输出；明确导出物来自文件对象、进程转储还是某段 VAD。
2. 对完整 PE 导出物先用 PEStudio/DiE 判断格式与架构，再运行 FLOSS；对裸区域仅在 `sc32/sc64` 依据充分时使用 shellcode 模式。
3. 对 verbose 输出中的函数位置、字符串内容和编码，与线程入口、VAD 权限、模块基址和原始字节对齐。
4. 若导出物截断或无头，保留不确定性，不把恢复出的单个字符串直接归因给某一进程行为。

### 场景三：面向 IOC 的复核清单

对每个可读线索建立一条记录：

```text
字符串：<原始输出>
类型/位置：decoded / <函数或偏移>
输入对象 SHA-256：<hash>
静态复核：HxD/PEStudio/DiE 的位置与结果
运行时复核：PID、PML/PCAP/服务日志/Volatility 对象、时间
状态：仅静态线索 / 已由独立证据支持 / 已排除
```

这使字符串能够服务于内存取证解释，而不是形成脱离证据链的 IOC 列表。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| `floss.exe` 无法启动 | 核对官方发布包哈希、系统架构与实际路径；用 `-h` 验证，勿从第三方站点补 DLL |
| 输出极多、噪声大 | 先保留默认完整输出，再用 `--only`、`--no` 或较大的 `-n` 创建辅助视图；不可丢弃原始输出 |
| 无 decoded 或 stack 输出 | 可能与格式、编译方式、壳、截断或分析能力有关；不等于不存在混淆或恶意逻辑 |
| JSON 无法复读 | 保存产生 JSON 的完整命令、版本和输入哈希；使用 `-l` 对同一原始 JSON 复读，不手工修改原件 |
| shellcode 模式结果无意义 | 重新核实导出边界、架构、VAD/线程来源；没有充分依据时回退到普通模式并保留不确定性 |

## 实战检查清单

- [ ] 已从官方 Releases 获取 FLOSS，并记录发布标签、二进制 SHA-256 与版本。
- [ ] 已对样本原件、工作副本、内存导出物和 FLOSS 输出建立哈希与来源链。
- [ ] 已保存默认完整输出、实际命令和必要的 JSON/详细输出。
- [ ] 未把 URL、域名、命令或 decoded 字符串直接作为行为或恶意结论。
- [ ] 已用 PEStudio、DiE、原始字节、动态记录或 Volatility 3 上下文完成复核。
- [ ] shellcode 模式已记录 `sc32/sc64` 选择依据和对应的内存对象信息。

## 官方资料

- [FLARE-FLOSS 项目与 Releases](https://github.com/mandiant/flare-floss)
- [官方安装文档](https://github.com/mandiant/flare-floss/blob/master/doc/installation.md)
- [官方使用文档](https://github.com/mandiant/flare-floss/blob/master/doc/usage.md)
