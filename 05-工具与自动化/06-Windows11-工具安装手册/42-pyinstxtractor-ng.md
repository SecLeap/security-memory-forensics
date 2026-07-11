# pyinstxtractor-ng 实战手册

> 适用范围：隔离分析环境中，对授权的 PyInstaller Windows PE 或 Linux ELF 工作副本进行离线容器信息查看与受控提取。严禁运行输入二进制、提取的 Python 代码、动态库或任何生成的脚本。

[pyinstxtractor-ng](https://github.com/pyinstxtractor/pyinstxtractor-ng) 用于从 PyInstaller 打包的 Windows PE 和 Linux ELF 中提取内容；项目提供独立发布包及 Python 使用方式。本手册只覆盖静态 --info 与普通提取，明确禁用面向运行提取物的 --one-dir 工作流。

## 获取与安装

### 1. 独立发布包（推荐）

1. 从 [官方 Releases](https://github.com/pyinstxtractor/pyinstxtractor-ng/releases) 下载隔离分析机对应的版本；原始包保存到 C:\Lab\Installers\pyinstxtractor-ng\。
2. 解压至 C:\Lab\Tools\pyinstxtractor-ng\，记录发布标签、下载 URL、许可证、压缩包和实际可执行文件 SHA-256。
3. 使用无害、自建的 PyInstaller 测试程序副本显示帮助或运行 --info 验证。验证对象不得是未知样本。

    Get-FileHash 'C:\Lab\Installers\pyinstxtractor-ng\<发布包>' -Algorithm SHA256
    Get-ChildItem 'C:\Lab\Tools\pyinstxtractor-ng' -Recurse -File | Get-FileHash -Algorithm SHA256
    Set-Location 'C:\Lab\Tools\pyinstxtractor-ng'
    .\pyinstxtractor-ng.exe --help

实际发布文件名可能随平台和版本变化；以解压包内文件和该版本 --help 为准。不要从未知镜像下载单文件二进制，也不要把工具目录加入生产主机 PATH。

### 2. Python 方式（仅在工具链已受控时）

需要自动化时，使用隔离虚拟环境并固定依赖版本；不要混入其他分析工具的 Python 环境。Python 安装只运行工具自身，不执行待提取对象。

    py -3.12 -m venv C:\Lab\venvs\pyinstxtractor-ng
    C:\Lab\venvs\pyinstxtractor-ng\Scripts\Activate.ps1
    python -m pip install --upgrade pip
    python -m pip install pyinstxtractor-ng
    pyinstxtractor-ng --help

如果项目当前发布说明要求不同的 Python 版本或安装名称，以官方文档为准，并将实际版本写入案例记录。

## 证据准备与目录隔离

    C:\Lab\Cases\LAB-001\
    ├─ 00-原始文件\                              # 原始可执行文件，只读
    ├─ 01-工作副本\
    ├─ 02-提取派生物\pyinstxtractor-ng\
    │  ├─ 输入副本\                               # 专门用于控制默认输出位置
    │  └─ candidate.exe_extracted\                # 工具产生的派生目录（示例）
    ├─ 03-静态识别\
    └─ 04-内存镜像与输出\

提取前，将工作副本复制到 02-提取派生物\pyinstxtractor-ng\输入副本\。这样工具在输入文件旁生成的默认提取目录也留在案例范围内。记录原件、工作副本、提取输入副本及输出目录中每个文件的 SHA-256、工具版本和完整命令。

## 使用方法

### 1. 先运行 --info（不提取）

--info 只显示 PyInstaller 元数据，不写出提取文件，是首选初筛步骤。

    $case = 'LAB-001'
    $input = "C:\Lab\Cases\$case\02-提取派生物\pyinstxtractor-ng\输入副本\candidate.exe"
    $out = "C:\Lab\Cases\$case\03-静态识别\$case-pyinstxtractor-ng-info.txt"
    Set-Location 'C:\Lab\Tools\pyinstxtractor-ng'
    .\pyinstxtractor-ng.exe --info $input | Tee-Object -FilePath $out
    Get-FileHash $input -Algorithm SHA256 | Tee-Object -FilePath $out -Append

记录识别出的 PyInstaller 元数据、目标平台、解析警告与工具版本。--info 未识别不能证明文件无害或不是 Python 打包文件，可能与格式、截断或工具版本有关。

### 2. 普通提取（只生成派生物）

在 --info 结果与输入哈希已留档后，进行一次普通提取。不同版本对输出目录命名可能略有差异；常见情况下会在输入文件同级创建输入文件名加 _extracted 的目录，因此不要在原件或通用工具目录中执行。

    $case = 'LAB-001'
    $input = "C:\Lab\Cases\$case\02-提取派生物\pyinstxtractor-ng\输入副本\candidate.exe"
    $log = "C:\Lab\Cases\$case\03-静态识别\$case-pyinstxtractor-ng-extract.txt"
    Set-Location 'C:\Lab\Tools\pyinstxtractor-ng'
    .\pyinstxtractor-ng.exe $input | Tee-Object -FilePath $log

完成后记录实际产生的目录、工具原始输出和所有派生物哈希：

    $root = "C:\Lab\Cases\LAB-001\02-提取派生物\pyinstxtractor-ng"
    Get-ChildItem $root -Recurse -File | ForEach-Object {
      $h = Get-FileHash $_.FullName -Algorithm SHA256
      [pscustomobject]@{Path=$_.FullName;Length=$_.Length;SHA256=$h.Hash}
    } | Export-Csv "$root\LAB-001-pyinstxtractor-ng-派生物-SHA256.csv" -NoTypeInformation -Encoding utf8

**禁止使用 --one-dir。**该选项服务于便捷地运行提取内容，不符合本仓库的静态取证流程。不得运行 main.py、任何 .py/.pyc、DLL、EXE、脚本、安装器或提取目录中的快捷方式，也不得在提取物上启动 Python 解释器。

### 3. 提取后静态分流

| 提取物类型 | 允许的下一步 | 禁止项 |
| --- | --- | --- |
| .pyc / Python 源码/资源 | 保留路径、哈希与原始字节；按后续获批的静态阅读流程分析 | 导入模块、执行、反编译后运行 |
| PE/DLL | PE-bear、DiE、PEStudio、FLOSS 做离线静态初筛 | 加载 DLL、双击 EXE、调试执行 |
| 配置/文本/证书 | HxD、FileInsight 离线查看，保存编码与偏移 | 访问其中 URL、使用凭据或提交在线服务 |
| 未识别二进制 | 记录大小、熵/字节、来源与提取日志 | 擅自改扩展名、伪造文件头或执行探测 |

## 与内存取证联动

### 场景一：内存导出的疑似 PyInstaller 进程映像

1. 保留完整内存镜像及其 SHA-256，在 Volatility 3/MemProcFS 中记录 PID、命令行、模块、VAD、文件对象/导出命令、地址范围和导出物 SHA-256。
2. 对导出物先使用 PE-bear/DiE 判断是否为完整 PE、架构和截断情况，再对工作副本运行 --info。
3. 提取出的 .pyc、资源或嵌入 PE 均建立新的派生物哈希；用路径、文件名和字符串仅形成静态线索。
4. 只有当线程/VAD/模块、磁盘/内存对象和时间线相互支持时，才能描述某对象与该进程相关；不能由提取成功推断代码已执行。

### 场景二：安装器提取后的二次容器

InnoExtractor/InnoUnpacker 提取的对象若静态识别为 PyInstaller，可将其作为新的工作副本进行 --info 和普通提取。案例记录中要串起：安装包原件哈希 → 第一层提取物哈希 → PyInstaller 输入副本哈希 → 第二层派生物哈希，且每一层都不执行。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| --info 不识别 | 记录完整输出；检查输入哈希、是否 PE/ELF、文件是否截断；不以失败推断无 PyInstaller 内容 |
| 工具无法启动 | 核验官方发布包、架构和实际文件名；以 --help 验证，不从第三方补 DLL |
| 输出目录位置意外 | 立即停止后记录目录；以后将输入副本放在案例派生物目录，避免污染原件目录 |
| 提取报错或只有部分文件 | 保存原始日志、版本和目录树；不运行原始文件“补齐”内容 |
| 想查看 .pyc 行为 | 不执行；仅走经过批准的离线静态阅读/反编译记录流程，并保留原始 .pyc 哈希 |

## 实战检查清单

- [ ] 已核验工具发布包/主程序、原件、工作副本、提取输入和派生物哈希。
- [ ] 已先保存 --info 原始输出，再做一次受控普通提取。
- [ ] 输入副本与默认输出目录均处于案例派生物目录内。
- [ ] 未使用 --one-dir，未运行输入程序、提取代码或任何提取文件。
- [ ] 内存来源已记录镜像哈希、PID、VAD/文件对象、导出命令和导出物哈希。

## 官方资料

- [pyinstxtractor-ng 官方项目](https://github.com/pyinstxtractor/pyinstxtractor-ng)
- [pyinstxtractor-ng 官方 Releases](https://github.com/pyinstxtractor/pyinstxtractor-ng/releases)
