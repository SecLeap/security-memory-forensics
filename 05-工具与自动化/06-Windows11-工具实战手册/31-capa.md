# mandiant/capa 实战手册

> 适用范围：隔离 Windows 11 分析虚拟机中的已授权 PE、ELF、.NET 模块、shellcode 导出物及其可追溯工作副本。capa 以规则匹配识别程序**可能具备的能力**，不执行输入文件；能力、ATT&CK/MBC 标签和命名空间均是待复核线索，不是已发生行为的证明。

[capa](https://github.com/mandiant/capa) 可分析可执行文件、shellcode 和部分动态报告，输出其认为程序能够执行的能力。本仓库的主线只使用其对磁盘工作副本与内存导出物的离线分析；不要将案例文件、capa JSON 或含敏感字符串的结果上传到在线 Explorer 或第三方服务。

## 获取与安装

### 1. 首选独立版

从 [官方 Releases](https://github.com/mandiant/capa/releases) 获取与分析机架构匹配的稳定版独立二进制。官方说明表明独立版无需安装，可在终端中直接运行。

1. 将下载原件保留在 `C:\Lab\Installers\capa\`，将工具解压/放置到 `C:\Lab\Tools\capa\`。
2. 记录发布标签、下载 URL、发布日期、二进制 SHA-256、规则包版本（或随发行版提供的规则修订信息）和许可证。
3. 规则会随发行版变化；比较或重跑历史案例时，必须固定并记录 `capa.exe` 与规则集版本，不能只记录“使用了 capa”。

```powershell
Get-FileHash 'C:\Lab\Installers\capa\<发布包或 capa.exe>' -Algorithm SHA256
Set-Location 'C:\Lab\Tools\capa'
.\capa.exe -h
```

完成标准：`-h` 能显示当前版本支持的参数，安装记录包含二进制哈希与规则版本。不要以未知样本作为安装验证对象；可使用已知良性、许可的测试 PE 副本。

### 2. Python 安装（仅自动化或二次开发）

若需要将 capa 嵌入脚本或研究规则，按 [官方安装文档](https://github.com/mandiant/capa/blob/master/doc/installation.md) 在独立虚拟环境中安装。手工取证优先使用独立版，避免与 Volatility、FLOSS 等工具的 Python 依赖相互污染。

```powershell
py -3.12 -m venv C:\Lab\venvs\capa
C:\Lab\venvs\capa\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install flare-capa
capa -h
```

Python 包默认不附带标准规则集和库识别签名；必须从 [capa-rules Releases](https://github.com/mandiant/capa-rules/releases) 获取已验证的规则发布包，并显式指定规则目录。签名目录也必须来自与 capa 版本对应、已验证的官方源代码/发行材料。

```powershell
$rules = 'C:\Lab\Rules\capa-rules-v<版本>'
$sigs = 'C:\Lab\Tools\capa-sigs-<版本>'
capa -r $rules -s $sigs 'C:\Lab\Cases\LAB-001\01-工作副本\candidate.exe'
```

如使用不同的受支持 Python 版本，应在案例记录中明确写出解释器与包版本、规则目录及签名目录哈希。自定义规则的开发环境与证据分析环境分离，规则修改不得覆盖官方规则原件。

## 证据准备与版本固定

```text
C:\Lab\Cases\LAB-001\
├─ 00-原始文件\
├─ 01-工作副本\
├─ 02-静态识别\capa\
│  ├─ LAB-001_<短哈希>_capa-default.txt
│  ├─ LAB-001_<短哈希>_capa-verbose.txt
│  ├─ LAB-001_<短哈希>_capa.json
│  └─ LAB-001_capa-commands.txt
└─ 04-内存镜像与导出物\
```

每次分析至少记录：输入 SHA-256、输入来源、capa 与规则版本、实际命令、执行时间、输出哈希和退出状态。内存导出物还必须记录完整镜像 SHA-256、采集信息、Volatility 插件与参数、PID/VAD/文件对象来源和导出时间。

**结论边界：**

- `create service` 匹配表示规则在该对象中找到了支持“可能创建服务”的特征，不表示系统中已创建服务。
- ATT&CK、MBC 等分类来自规则元数据；它们是归类和检索辅助，不能替代对 API、字符串、代码位置和运行时记录的复核。
- 默认输出仅展示顶层匹配；`-v` 显示嵌套匹配，`-vv` 展示规则为何命中以及命中位置。撰写报告时，能力名必须能回溯到 `-vv` 证据。

## 使用方法

### 1. 默认初筛与可复现输出

先对工作副本运行默认输出，保存完整文本，不要只复制屏幕上几条能力名称。

```powershell
$case = 'LAB-001'
$sample = 'C:\Lab\Cases\LAB-001\01-工作副本\candidate.exe'
$outDir = "C:\Lab\Cases\$case\02-静态识别\capa"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

Set-Location 'C:\Lab\Tools\capa'
.\capa.exe $sample | Tee-Object -FilePath "$outDir\$case-capa-default.txt"
Get-FileHash $sample -Algorithm SHA256 | Tee-Object -FilePath "$outDir\$case-capa-commands.txt" -Append
```

默认输出适合建立初始能力地图。按命名空间分组，例如 `communication`、`host-interaction`、`persistence`、`data-manipulation`，再将每个高价值能力转换成待验证问题，而不是直接转写为案件结论。

### 2. 详细证据与 JSON

`-vv` 展示规则匹配链及函数/地址位置，是人工复核的主输出；`-j` 输出结构化 JSON，适合本地留档和离线查看。

```powershell
.\capa.exe -vv $sample | Tee-Object -FilePath "$outDir\$case-capa-verbose.txt"
.\capa.exe -j $sample | Out-File -FilePath "$outDir\$case-capa.json" -Encoding utf8
Get-FileHash "$outDir\$case-capa.json" -Algorithm SHA256 |
  Tee-Object -FilePath "$outDir\$case-capa-commands.txt" -Append
```

复核每一项时保存：能力名、命名空间、规则名/版本、`-vv` 中的函数或地址、触发特征（API、字符串、常量等）、对应的 PEStudio/DiE/FLOSS/HxD 证据，以及后续动态或内存验证状态。capa Explorer 的在线版本不用于受限案例；如需可视化，仅在已批准的离线本地组件中加载副本结果。

### 3. 聚焦规则与函数

对大文件或已有明确问题时，可缩小范围；仍应先保留一次完整默认/详细结果。

```powershell
# 仅运行元数据包含 communication 的规则
.\capa.exe -t communication $sample |
  Tee-Object -FilePath "$outDir\$case-capa-communication.txt"

# 仅复核已由 Ghidra/x64dbg 确认的函数地址
.\capa.exe -v --restrict-to-functions 0x4019C0,0x401CD0 $sample |
  Tee-Object -FilePath "$outDir\$case-capa-functions.txt"
```

`-t` 根据规则元数据筛选，可能降低覆盖面；`--restrict-to-functions` 中的地址必须来自同一输入样本、同一映像基址和已记录的反汇编结果。ASLR、重定位、内存导出物截断都会使地址不直接可比。

### 4. 规则管理

capa 依赖规则集识别能力。不要在案例执行中临时改写默认规则，也不要把私有规则混入官方规则目录而不留版本痕迹。

1. 将官方规则集作为只读基线，记录来源提交/发行版和目录哈希。
2. 自定义规则复制到 `C:\Lab\Rules\capa-custom\<版本>\`，写明目的、作者、测试样本哈希和已知误报边界。
3. 运行前明确使用的规则目录及规则版本；在报告中区分“官方规则命中”与“本地自定义规则命中”。
4. 任何规则命中都以 `-vv`、原始字节与相关代码位置复核；规则本身不是事实来源。

## 与内存取证的联合使用

### 场景一：磁盘 PE 与内存导出 PE 的能力对比

1. 保存全量内存镜像 SHA-256、采集记录及 Volatility 3 原始输出。
2. 使用 [Volatility 3 实战手册](../02-Volatility3-实战手册.md) 记录目标 PID、命令行、模块、VAD、线程起始地址、网络对象，并导出来源明确的候选文件。
3. 对磁盘工作副本和内存导出物分别计算哈希，分别运行 capa 默认、`-vv` 和 JSON 输出。
4. 比较能力、函数位置、格式与完整性差异。差异可能来自截断、重定位、加载后的补丁、不同版本或静态分析限制；不应直接等同于注入或恶意。
5. 对有意义的匹配，回到 VAD 保护属性、线程入口、模块映射、PEStudio/DiE 结构结果和原始字节验证。

### 场景二：疑似 shellcode 或无文件代码区域

capa 可处理 shellcode 文件，但只有在导出边界、处理器架构和来源已明确时才应使用。先保留 VAD 的起止地址、页保护、所属 PID、线程入口、导出方式和完整镜像哈希；使用当前版本 `capa -h` 中提供的输入格式/架构选项，并将所选格式写入命令记录。

若对象没有完整 PE 头、架构不确定或 capa 无法解析，保留“未能可靠解析”的结果；继续以 Volatility 对象关系、原始字节和反汇编验证，不能把零匹配解释为“无能力”或“无害”。

### 场景三：受控实验中的静态—动态—内存证据链

1. 测试前，对授权样本工作副本运行 capa、PEStudio、DiE 和 FLOSS，留存完整输出和哈希。
2. 测试中，用 Noriben/Procmon、Wireshark 或 FakeNet-NG 留存受控执行记录。
3. 在关键时点采集全量内存镜像；在 Volatility 3 中回溯目标进程、模块、VAD、线程及网络对象。
4. 将 capa 的每项能力拆为验证项。例如 `communication/http/client` 需要 PCAP/FakeNet 日志和 PID 时间关联；`persistence/service` 需要 Procmon/注册表或服务相关证据；`process/inject` 需要 VAD、线程和进程关系证据。

报告中应写作：`capa（版本/规则版本）在样本哈希 <…> 中匹配到 <能力>；-vv 证据位于 <地址/函数>；在本次实验的 <PML/PCAP/内存对象> 中已验证/未验证 <行为>。`

## 已知限制与排错

| 情况 | 处理方式 |
| --- | --- |
| 提示可能加壳 | 官方明确指出加壳/混淆会使静态 capa 结果不完整或误导；记录警告，用 DiE、PEStudio、原始字节和受控内存导出物继续复核，不以少量匹配下结论 |
| 安装包、运行时封装或 AutoIt 等输入 | 官方将其列为可能误导或不完整的场景；保留原始输出，分析实际载荷或导出对象，而不是强行解释总览 |
| 默认输出与预期不一致 | 默认只展示顶层规则；使用 `-v` 查看嵌套匹配，使用 `-vv` 定位规则依据 |
| 某能力没有命中 | 规则覆盖、包装函数、子函数、循环、混淆或输入不完整都可能导致漏报；“未命中”不能证明没有该能力 |
| 规则/版本不同导致结果不同 | 对比二进制 SHA-256、capa 版本、规则提交/目录哈希、命令和输入来源，再在同一基线复跑 |
| 输入来自内存但无法解析 | 检查导出边界、文件头、架构与 VAD 来源；不要用伪造的头或未知格式强行获得结果 |

## 实战检查清单

- [ ] 已从官方 Releases 获取 capa，并记录二进制与规则集版本、来源和哈希。
- [ ] 已为原件、工作副本和内存导出物建立可追溯的哈希/来源链。
- [ ] 已保存默认、`-vv` 和 JSON 原始输出及实际命令。
- [ ] 已将能力和 ATT&CK/MBC 标签写为规则线索，而非已发生行为。
- [ ] 每项关键结论均能回溯到 `-vv` 位置、原始字节/反汇编和内存或动态上下文。
- [ ] 已记录加壳、截断、包装函数和规则覆盖等限制。

## 官方资料

- [mandiant/capa 项目与 Releases](https://github.com/mandiant/capa)
- [官方使用说明](https://github.com/mandiant/capa/blob/master/doc/usage.md)
- [官方限制说明](https://github.com/mandiant/capa/blob/master/doc/limitations.md)
- [官方规则库](https://github.com/mandiant/capa-rules)
