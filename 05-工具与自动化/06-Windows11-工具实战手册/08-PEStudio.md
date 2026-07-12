# PEStudio 9.61 实战手册

> 适用范围：在隔离 Windows 11 分析虚拟机中，对已获授权的 Windows PE 文件副本及内存导出候选物进行**离线静态初筛**。PEStudio 不执行被打开的 PE 文件，但其标记、风险分值和 API 提示都只是分析线索，不能代替内存上下文或行为证据。

PEStudio 9.61（basic）是便携式 ZIP 包，解压后无需安装且不修改运行系统。请特别注意许可边界：官方 basic 版仅限私人恶意软件分析用途；职业或企业环境应使用具备相应许可的 professional 版。[官方 9.61 下载页](https://www.winitor.com/download2) 与 [功能/许可说明](https://winitor.com/tools/pestudio/current/pestudio-features.pdf) 是本手册的唯一下载与功能依据。

## 获取与安装

### 1. 获取、校验与放置

1. 仅从 [Winitor 官方下载页](https://www.winitor.com/download2) 获取 `pestudio 9.61 (basic)` ZIP；不要从搜索广告页、重打包站或截图中来源不明的快捷方式获取。
2. 将下载原件保留在 `C:\Lab\Installers\PEStudio\`，解压到 `C:\Lab\Tools\PEStudio-9.61\`；原始 ZIP 不覆盖、不改名为样本文件。
3. 当前官方页面列出的 PEStudio 9.61 basic ZIP SHA-256 为：

```text
C1E2D0C1FBF5951486CF3D850CC24B11B66E25E0A5B77A623E2EB13FFAD9DDD9
```

下载时仍须以官方页面当时显示的校验值为准，并将页面日期、URL 与实际结果写入安装记录。

```powershell
Get-FileHash 'C:\Lab\Installers\PEStudio\pestudio.zip' -Algorithm SHA256
Expand-Archive 'C:\Lab\Installers\PEStudio\pestudio.zip' 'C:\Lab\Tools\PEStudio-9.61'
Get-ChildItem 'C:\Lab\Tools\PEStudio-9.61' -Recurse -File | Select-Object FullName,Length
```

4. 在 Win11 分析机创建快照并记录 PEStudio 版本、ZIP 哈希、解压目录与操作者。更新工具或替换配置前，先保留上一版目录和基线输出。

### 2. 验证与最小使用

1. 在工具目录运行 `pestudio.exe`（以实际压缩包内文件名为准）。
2. 使用一个已知良性的 Windows 可执行文件副本做首次打开测试；不要为了验证安装而运行或双击未知样本。
3. 在“File/Open file”中选择副本，确认能看到基本文件信息、哈希和 PE 结构项目；关闭后记录版本和测试时间。

完成标准：工具可在隔离 VM 中打开良性 PE 副本，且安装档案包含 ZIP 哈希与版本。basic 版没有 `pestudiox.exe` 命令行批处理和 XML 报告功能；不要在 basic 版中编造或依赖这些自动化功能。

## 证据准备与操作原则

### 样本与输出目录

```text
C:\Lab\Cases\LAB-001\
├─ 00-原始文件\            # 只读原件
├─ 01-工作副本\            # PEStudio 打开的副本
├─ 02-静态识别\PEStudio\  # 截图、人工记录、哈希
├─ 03-动态记录\
└─ 04-内存镜像与导出物\
```

1. 先对原件和工作副本计算 SHA-256，记录来源、获取时间、文件大小、操作者和复制关系。
2. 在 PEStudio 中仅打开工作副本；不通过资源管理器双击样本，也不依赖文件扩展名判断真实类型。
3. 截图时应同时保留样本短哈希、工具版本、项目名称和关键字段；文件名示例：`LAB-001_a1b2c3d4_PEStudio-9.61_imports.png`。
4. 不修改原件、PE 头、节表或资源。需要实验性修改时，建立新副本并单独计算哈希。

### VirusTotal 分数的边界

官方说明中，PEStudio 查询 VirusTotal 时提交的是文件 MD5 而不是文件本身，并可通过 XML 开关禁用。但哈希本身也可能泄露样本已被分析这一事实，且返回结果属于外部情报线索。默认在离线实验环境禁用外部查询；只有在授权、网络隔离策略允许且记录查询时间/MD5 的条件下才启用。VirusTotal 分数不能替代本地静态和内存证据。

## 使用方法

### 1. 十分钟静态初筛流程

1. **文件总览与哈希**：记录路径、大小、MD5/SHA-1/SHA-256、PE 位数、目标子系统、时间戳和签名状态。哈希是后续所有记录的主键。
2. **Indicators（指示项）**：浏览被标记的项目，记录规则名称、类别与对应字段。标红或高分表示“需要复核”，不等于恶意判定。
3. **Headers / Sections（头部与节）**：检查机器架构、入口点、节数量、节名、原始大小与虚拟大小、节权限、熵和异常时间戳。关注可写可执行节、异常节名、零填充/高熵或入口点落点异常，但分别记录观察与推断。
4. **Libraries / Imports / Exports（库、导入、导出）**：记录 DLL 及与文件、注册表、进程、服务、网络、加密和加载相关的 API 线索；API 名称只描述“可能具备的能力”，不能证明已调用。
5. **Strings / Resources / Manifest / Version / Overlay**：记录 URL、IP、域名、路径、互斥体、命令行、嵌入资源、清单权限、版本信息矛盾及附加数据。每项都要保留偏移或界面位置，并回到原始字节复核。
6. **形成假设而非结论**：把观察转换为待验证问题，例如“导入表存在网络相关 API，需用 Procmon/Wireshark/内存 socket 证据验证是否在本次运行中使用”。

### 2. 常见页面的复核映射

| PEStudio 观察 | 可能含义 | 必须的下一步 |
| --- | --- | --- |
| PE 架构、子系统、入口点 | 目标运行环境与初始控制流线索 | HxD/CFF Explorer 复核 PE 头；Ghidra 查看入口点附近代码 |
| 高熵、异常节或 overlay | 压缩、加壳、嵌入数据或截断的可能性 | 用 DiE、HxD 比较节布局和原始字节；不要据此直接认定“加壳” |
| 导入 `VirtualAlloc`、进程/线程、网络、注册表相关 API | 可能具备对应功能 | Procmon/Noriben、Wireshark/FakeNet-NG 及 Volatility 3 交叉验证运行时证据 |
| 可疑字符串、URL、IP、路径 | 可用于检索或时间线关联的候选 IOC | 在原始字节中复核；与 PCAP、DNS/HTTP 日志、进程命令行对齐 |
| 签名、版本信息或资源品牌不一致 | 冒充、篡改或构建过程差异的线索 | 验证证书链、文件来源和资源；将“信息不一致”与“恶意”分开写 |
| 缺失导入、头部残缺、无法解析 | 文件可能被截断、手工映射或不是完整磁盘 PE | 记录导出边界和来源；转向 VAD、线程入口、内存保护与原始字节 |

### 3. 手工记录模板

```text
案例号：LAB-001
对象：candidate.exe（工作副本）
SHA-256：<hash>
工具：PEStudio 9.61 basic；外部 VT 查询：禁用/已授权（时间、MD5）
观察：x64 PE；入口点 <RVA>；<节名> 节高熵；导入中出现 <API>
复核：HxD 偏移 <offset>；DiE 结果 <result>；Volatility PID/VAD <value>
结论边界：上述为静态线索；是否在运行时使用由 <证据名称> 证明/尚未证明。
```

## 与内存取证的联合使用

### 场景一：磁盘 PE 与内存导出物的对比

1. 先保存完整内存镜像的 SHA-256、采集记录和 Volatility 3 原始输出。
2. 记录关联进程的 PID、命令行、模块、VAD、线程起始地址与 socket；再按照 [Volatility 3 实战手册](../02-Volatility3-实战手册.md) 导出有明确来源的候选对象。
3. 分别为磁盘工作副本与内存导出物计算哈希，并分别在 PEStudio 中检查架构、入口点、节表、导入、资源与 overlay。
4. 将差异分类为：完整性/截断、加载时重定位、磁盘与内存版本不同，或尚待解释。只有 VAD 权限、线程入口、映射关系和原始字节相互支持时，才可描述为进程中的可执行 PE 对象。

### 场景二：手工映射或无文件候选区域

当内存区域没有完整 `MZ`/`PE\0\0` 头、PEStudio 无法完整解析时，不要补造文件头以获得漂亮报告。应保留区域起止地址、页保护、所属进程、导出方法和原始字节；使用 Volatility 的 VAD/线程/进程关系解释上下文。PEStudio 可作为“解析能力受限”的记录，而非排除或确认无文件执行的工具。

### 场景三：受控实验闭环

1. **测试前**：PEStudio + DiE 记录样本结构、静态 API/字符串线索与哈希。
2. **测试中**：Noriben/Procmon 记录文件、注册表、进程事件；Wireshark 或 FakeNet-NG 记录受控网络证据。
3. **关键时刻**：采集全量内存镜像并立即计算哈希。
4. **测试后**：Volatility 3 将 PID、命令行、VAD、模块、线程和网络对象与 PEStudio 线索对齐。

报告应使用“静态导入提示可能具备 X 能力；在 `<时间>` 的 `<PML/PCAP/内存对象>` 中观察到/未观察到 X”的格式，避免将导入 API 直接写成行为事实。

## 常见问题与排错

| 现象 | 原因与处理 |
| --- | --- |
| 打不开或无法解析文件 | 确认打开的是工作副本；以 HxD 检查头部、大小与截断；将“无法解析”作为结果保留 |
| Indicators 很多或分数很高 | 分数是规则提示；逐项查看对应字段并用原始字节、DiE、CFF Explorer/Ghidra 和动态证据复核 |
| 看不到批量/XML 导出 | 这是 basic 与 professional 的功能差异；不要下载破解包或替换未知二进制文件 |
| VirusTotal 结果为空或不一致 | 检查是否已禁用外部查询、MD5 是否相同及查询时间；不要把外部结果当作本地证据 |
| 工具或样本被防病毒告警 | 仅在隔离 VM 内，从官方 ZIP 重新核验哈希；记录告警，勿在生产主机设置不受控排除项 |

## 实战检查清单

- [ ] 已确认 basic 版的私人用途许可满足当前使用场景，其他场景已取得相应 professional 许可。
- [ ] 已保存官方 ZIP、下载信息与 SHA-256，且仅在隔离 Win11 VM 使用。
- [ ] 已为原件、工作副本和内存导出物分别记录哈希及来源。
- [ ] 已保留 PEStudio 9.61 的关键截图/手工记录与外部查询状态。
- [ ] 已将 Indicators、分数、API 和字符串标注为线索，而不是行为结论。
- [ ] 已用原始字节、DiE/CFF Explorer/Ghidra 或 Volatility 3 上下文完成交叉验证。

## 官方资料

- [PEStudio 9.61 basic 官方下载](https://www.winitor.com/download2)
- [PEStudio 版本与许可边界](https://www.winitor.com/download)
- [PEStudio 9.61 功能对照](https://winitor.com/tools/pestudio/current/pestudio-features.pdf)
