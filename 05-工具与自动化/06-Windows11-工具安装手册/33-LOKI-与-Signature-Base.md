# LOKI + signature-base 实战手册

> 适用范围：隔离分析机中，对从内存镜像恢复、导出或明确关联的**工作副本目录**进行 IOC/YARA 辅助复核。LOKI 与 signature-base 不是 RAM 镜像解析器，不能替代 WinPmem、Volatility 3 或 MemProcFS；不在默认流程中扫描生产终端、全盘、实时进程或原始内存镜像。

[LOKI](https://github.com/Neo23x0/Loki) 是 IOC/YARA 扫描器，使用文件名 IOC、哈希 IOC、YARA 规则等方式进行匹配；[signature-base](https://github.com/Neo23x0/signature-base) 是供 LOKI/THOR Lite 使用的 YARA 与 IOC 数据库。两者必须作为一个**版本固定的组合**管理：扫描器版本、signature-base 提交、规则/IOC 文件哈希和实际命令共同构成可复现证据。

## 版本状态与使用边界

LOKI Python 项目已被维护者标记为弃用并处于非活跃维护状态，公开 release 也较早。因此：

- 仅在需要复现既有 LOKI 结果、进行已授权教学实验，或经验证的受控离线工作流中使用；
- 不把“最新下载”自动等同于最新检测能力；每次分析冻结扫描器与规则库版本；
- 对新部署先完成兼容性、性能和误报测试；不因 LOKI 报告结果直接处置或定性；
- 本手册不使用 LOKI 的实时进程、网络连接或全盘扫描能力，避免将纯内存取证仓库扩展为终端巡检流程。

signature-base 的 `iocs\` 包含 IOC CSV，`yara\` 包含 YARA 规则，并采用 Detection Rule License（DRL）1.1（部分规则可能声明其他许可）。使用、分发或合并规则前应核对当前许可证与规则元数据。

## 获取、组合与版本冻结

### 1. 在更新工作站准备离线分析包

不要在案例分析机或隔离实验机中运行自动更新。应在经批准的更新工作站拉取代码/发布物、检查版本后，将固定副本连同清单转移到分析机。

推荐从源代码创建可审计组合包：

```powershell
Set-Location C:\Staging
git clone --recurse-submodules https://github.com/Neo23x0/Loki.git Loki
git -C .\Loki submodule status
git -C .\Loki rev-parse HEAD
git -C .\Loki\signature-base rev-parse HEAD
```

`--recurse-submodules` 是关键：仅下载 LOKI ZIP 不会自动获得 signature-base 子仓库。若使用 LOKI 官方发布包，则从官方 signature-base 仓库获取同样经过记录的副本，并将其置于 LOKI 期望的 `signature-base\` 目录结构中；先在良性测试目录验证规则能加载。

### 2. 生成并保留版本清单

```powershell
$bundle = 'C:\Staging\Loki'
git -C $bundle rev-parse HEAD | Set-Content "$bundle\BUNDLE-LOKI-COMMIT.txt"
git -C "$bundle\signature-base" rev-parse HEAD |
  Set-Content "$bundle\BUNDLE-SIGNATURE-BASE-COMMIT.txt"
Get-ChildItem $bundle -Recurse -File | Get-FileHash -Algorithm SHA256 |
  Export-Csv "$bundle\BUNDLE-SHA256.csv" -NoTypeInformation -Encoding utf8
```

转移到离线分析机后再计算包清单哈希并比对。保留 LOKI 的 GPL-3.0 许可、signature-base 的 DRL 许可和各规则自身元数据；不得通过删除许可证或混入未记录规则改变包的来源。

### 3. 分析机安装与最小验证

```text
C:\Lab\Tools\LOKI\
├─ loki.exe / loki.py
├─ signature-base\
│  ├─ iocs\
│  └─ yara\
├─ BUNDLE-LOKI-COMMIT.txt
├─ BUNDLE-SIGNATURE-BASE-COMMIT.txt
└─ BUNDLE-SHA256.csv
```

Windows 发布版通常提供无需额外依赖的打包可执行文件；源码版使用 `loki.py`，需要 Python、`yara-python`、`psutil`、`colorama` 等依赖。优先使用已验证的发布包；若必须运行源码版，创建独立虚拟环境并把 Python/依赖版本写入清单，不能与 Volatility 或其他工具环境混用。

```powershell
Set-Location 'C:\Lab\Tools\LOKI'
.\loki.exe -h
# 源码版等价验证（仅在已建立独立虚拟环境时）
python .\loki.py -h
```

完成标准：帮助可显示，`signature-base\iocs` 与 `signature-base\yara` 均存在，且良性测试目录扫描能完成并产生日志。不要用未知样本、原始 RAM 镜像或系统根目录进行安装验证。

## 内存取证中的输入与输出管理

### 1. 只扫描派生工作副本

```text
C:\Lab\Cases\LAB-001\
├─ 00-原始镜像\
├─ 02-MemProcFS-导出\       # 复制出的 VFS 导出物
├─ 03-Volatility3-输出\     # 插件原始输出与来源记录
├─ 04-候选文件工作副本\     # dumpfiles/文件恢复/进程导出后的副本
└─ 05-LOKI-扫描输出\
```

可扫描输入仅限：

- 由 Volatility 3 导出且记录了插件、参数、对象来源、PID/VAD（如适用）的候选文件；
- 由 MemProcFS VFS 复制到案例目录、并保留 VFS 路径和导出哈希的恢复文件；
- 明确属于案例、可重新生成的进程转储或文件工作副本。

禁止把原始 RAM 镜像、原始证据卷、整个 `C:\`、在线共享目录或实时进程作为 LOKI 的默认扫描对象。LOKI 对目录中文件进行 IOC/YARA 匹配，不解释内存对象关系；扫描目标必须先由内存取证工作流限定范围。

### 2. 扫描前记录

对输入目录生成文件清单与哈希；将输入目录、LOKI 包版本、signature-base 提交和命令写入案例记录。

```powershell
$input = 'C:\Lab\Cases\LAB-001\04-候选文件工作副本'
$out = 'C:\Lab\Cases\LAB-001\05-LOKI-扫描输出'
New-Item -ItemType Directory -Force -Path $out | Out-Null
Get-ChildItem $input -Recurse -File | Get-FileHash -Algorithm SHA256 |
  Export-Csv "$out\LAB-001-input-hashes.csv" -NoTypeInformation -Encoding utf8
```

## 使用方法

### 1. 离线目录扫描（推荐）

以下命令将扫描限制在案例工作副本目录，禁用实时进程扫描和网络监听，并输出日志/CSV。先以小型、良性的测试目录验证参数，再扫描案例目录。

```powershell
$input = 'C:\Lab\Cases\LAB-001\04-候选文件工作副本'
$out = 'C:\Lab\Cases\LAB-001\05-LOKI-扫描输出'
Set-Location 'C:\Lab\Tools\LOKI'

.\loki.exe -p $input -s 10240 -l "$out\LAB-001-loki.log" `
  --csv --noprocscan --nolisten --dontwait
```

源码版将 `.\loki.exe` 替换为 `python .\loki.py`。`-p` 指定目录，`-s` 指定最大扫描文件大小（KB，默认 5000），`-l` 指定日志。提高 `-s` 可减少大文件被跳过的风险，也会增加运行时间；必须把实际值记录进案例。`--csv` 便于结构化留档，`--noprocscan` 与 `--nolisten` 确保本流程不执行实时进程/连接检查。

完成后对日志、CSV 与输入清单计算 SHA-256，并保留控制台输出和退出状态。不要用 `--force` 绕过工具硬编码排除项；如某对象必须复核，复制该对象到干净的案例子目录后单独扫描，并记录原因。

### 2. 聚焦某个导出物

对于来自特定 PID/VAD/文件对象的单个副本，建立单独目录，以避免跨对象匹配混淆归属：

```powershell
$one = 'C:\Lab\Cases\LAB-001\04-候选文件工作副本\PID-1234_VAD-00007ff6\'
.\loki.exe -p $one -l "$out\LAB-001-PID-1234-loki.log" `
  --csv --noprocscan --nolisten --dontwait
```

在报告中将命中关联到输入文件 SHA-256、Volatility/MemProcFS 来源、PID、VAD 地址范围和提取时间。不要因为 LOKI 文件扫描结果就把命中自动归因给整个进程或某次网络行为。

### 3. 结果解读

LOKI 报告常用 GREEN/YELLOW/RED 表示不同等级的匹配提示。它们不是裁决等级：

| 匹配类型 | 表示什么 | 必须复核 |
| --- | --- | --- |
| 文件名 IOC | 路径/名称满足正则或 IOC | 实际路径、文件哈希、来源对象和误报条件 |
| 哈希 IOC | 当前工作副本哈希匹配 IOC | SHA-256/MD5 等算法类型、IOC 来源与规则版本、文件来源链 |
| YARA | 文件字节满足某条规则条件 | 规则文件/行、规则元数据、匹配字符串/偏移、原始字节与对象上下文 |
| C2/进程相关提示 | 依赖实时对象检查 | 本手册已禁用；如其他流程产生结果，不能纳入本离线扫描结论 |

建议结论格式：`LOKI <版本> + signature-base <提交> 在工作副本 SHA-256 <…> 中命中规则 <…>；匹配位置/条件为 <…>；该副本源自 <Volatility/MemProcFS 路径、PID/VAD>；经 <原始字节/其他规则/行为证据> 复核后状态为 <支持、待定或误报>。`

## signature-base 规则与 IOC 管理

### 1. 不直接把规则库当作通用 YARA 目录

signature-base 中部分 YARA 规则使用 LOKI/THOR Lite 的外部变量；若直接交给其他 YARA 工具，可能出现 `undefined identifier`。`yara\external-variable-rules.txt` 列出了这类规则。优先通过 LOKI 使用完整规则库；若必须与 MemProcFS 或其他引擎联用，建立单独的、经过语法与变量检查的规则子集，并记录被排除规则列表、原因和规则哈希。

不要在案例目录中删除或修改官方规则来“消除报错”。复制出有版本的兼容子集，在其 README 中记录来源提交、筛选脚本、外部变量处理方式和许可证边界。

### 2. 私有 IOC/规则

私有 IOC 或自写规则必须放在与官方规则库不同的目录，例如 `C:\Lab\Rules\LOKI-Custom\<版本>\`，并包含作者、来源、创建时间、测试对象哈希、误报边界和许可证。运行时记录是否加载了该自定义集，报告中明确区分：

- 官方 signature-base 命中；
- 本地自定义 IOC/规则命中；
- 未能加载或因兼容性被排除的规则。

## 与 Volatility 3、MemProcFS 的联合分析

### 场景一：从 VAD/文件对象到规则命中

1. 用 [Volatility 3 实战手册](../02-Volatility3-实战手册.md) 定位进程、VAD、线程和可导出的文件对象；保存完整插件输出。
2. 将导出物复制为工作副本，记录 SHA-256、PID、VAD 范围、对象地址和导出时间。
3. 用 LOKI + 固定 signature-base 扫描该工作副本目录；保存日志、CSV、版本清单和输入清单。
4. 若命中，回到原始字节、VAD 保护、线程入口、PEStudio/DiE/FLOSS/capa 结果复核；若未命中，不能排除无文件代码、未覆盖家族、加壳或截断。

### 场景二：MemProcFS 恢复文件的辅助筛选

1. 以 [MemProcFS 实战手册](32-MemProcFS.md) 只读挂载工作副本镜像，并将 `forensic\files` 等恢复结果复制到案例目录。
2. 对复制结果建立哈希和 VFS 来源清单，再按目录扫描流程运行 LOKI；不直接扫描 MemProcFS 挂载盘或原始镜像。
3. 规则命中后，以 MemProcFS VFS 路径、文件恢复来源及 Volatility 对象关系确定归属；恢复文件可能不完整，匹配与未匹配都需标注完整性限制。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| ZIP 版缺少 signature-base | 使用 `git clone --recurse-submodules` 重新建立组合包，或按固定版本单独获取 signature-base 并验证目录/哈希 |
| YARA 出现 `undefined identifier` | 检查是否脱离 LOKI 使用了依赖外部变量的规则；建立可审计兼容子集，不修改官方原件 |
| 输出/命中与历史案例不同 | 比较 LOKI 版本、signature-base 提交、输入哈希、最大文件大小、扫描参数和自定义规则加载状态 |
| 扫描过慢或文件被跳过 | 查看 `-s` 设置、输入范围和日志；缩小至来源明确的导出目录，而不是扫描全盘 |
| 防病毒告警 LOKI | 仅在隔离分析机从官方来源复核包哈希；记录告警，不在生产终端建立无控制的排除项 |
| 出现 GREEN/YELLOW/RED | 将其视为优先级提示；逐条复核 IOC/规则、原始字节和内存对象关系，不直接下结论 |

## 实战检查清单

- [ ] LOKI 与 signature-base 已作为同一固定组合包记录版本、提交、许可和 SHA-256。
- [ ] 已确认 Python LOKI 的弃用状态，并完成受控环境兼容性/误报验证。
- [ ] 扫描范围仅为案例工作副本目录，未扫描原始镜像、全盘、实时进程或网络对象。
- [ ] 已使用 `--noprocscan --nolisten`，并保存完整命令、日志、CSV 和输入哈希清单。
- [ ] YARA/IOC 命中已关联至具体文件哈希、Volatility/MemProcFS 来源及 PID/VAD（如适用）。
- [ ] 对外部变量规则、自定义规则和许可证限制已有独立记录。

## 官方资料

- [Neo23x0/LOKI 项目与使用说明](https://github.com/Neo23x0/Loki)
- [Neo23x0/signature-base 规则与 IOC 库](https://github.com/Neo23x0/signature-base)
- [signature-base 许可证](https://raw.githubusercontent.com/Neo23x0/signature-base/master/LICENSE)
