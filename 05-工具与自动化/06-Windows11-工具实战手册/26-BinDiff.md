# Zynamics BinDiff 实战手册

> 适用范围：在离线分析机中，对两个来源明确、同架构且完整性可评估的二进制工作副本进行函数/基本块级差异比较。BinDiff 的匹配与相似度是分析排序线索，不能单独证明同源、恶意、执行行为或内存注入。

[Zynamics BinDiff](https://www.zynamics.com/bindiff/manual/) 是以函数控制流图等结构特征比较二进制的工具，适合研究版本差异、已知参考文件与候选导出物之间的变化。BinDiff 8 已开源，并支持 IDA 插件；Ghidra 的 BinExport 集成在官方文档中仍被标为实验性/β级。默认优先使用版本固定的 IDA + BinDiff 流程，Ghidra 导出仅作为经过验证的备选。

## 获取与安装

### 1. Windows 安装与组件校验

1. 从 [BinDiff 官方页面/发布页](https://www.zynamics.com/bindiff.html) 获取 `bindiff8.msi`，保留原始 MSI 至 `C:\Lab\Installers\BinDiff\`。
2. 记录版本、下载 URL、文件名、SHA-256、许可证和安装时间；安装需管理员权限，仅在隔离分析 VM 进行。
3. 安装向导要求指定 Hex-Rays IDA Pro 路径；仅指向经授权、版本已记录的 IDA 安装。不要覆盖/替换 IDA 插件目录中的未知文件。
4. 以两个良性、同架构测试文件建立最小 diff，确认 IDA 中 `Ctrl+6` 可打开 BinDiff 插件。

```powershell
Get-FileHash 'C:\Lab\Installers\BinDiff\bindiff8.msi' -Algorithm SHA256
Get-ChildItem 'C:\Program Files\BinDiff' -Recurse -File | Get-FileHash -Algorithm SHA256
```

记录 BinDiff 配置文件版本和 IDA/Ghidra/BinExport 版本。不要在案例过程中调整匹配算法顺序或置信度阈值；若进行实验性配置变更，复制原配置并创建独立、明确标注的实验结果。

### 2. Ghidra 备选集成

BinDiff 包含的 Ghidra BinExport 扩展为实验性支持，通常需要在 Ghidra 中手动导出再进行 diff。仅在以下条件满足时使用：Ghidra、扩展和 BinDiff 版本已记录；两个导出均来自同样的加载器/语言规范；良性样本已验证导出与匹配流程。否则使用 IDA 路径，或只保留静态分析而不生成差异结论。

## 输入、项目与证据边界

```text
C:\Lab\Cases\LAB-001\
├─ 00-原始文件\
├─ 01-工作副本\
│  ├─ 参考文件\              # Primary：已知基线
│  └─ 候选文件\              # Secondary：待比较对象
├─ 02-反汇编项目\
├─ 03-BinExport\
├─ 04-BinDiff-结果\
└─ 05-内存镜像与输出\
```

开始前确认：两文件 SHA-256、来源、采集/导出方式、架构、格式、大小、完整性、是否加壳/截断、反汇编器版本、image base 和自动分析配置。原件不导入，BinDiff 只处理工作副本与其 BinExport/数据库派生物。

比较方向必须固定：`Primary` 选已知参考/基线，`Secondary` 选候选/内存导出物。若需要双向研究，建立第二个独立结果，不覆盖第一个 `.BinDiff` 结果文件。

以下情形不适合直接比较：不同架构、不同文件格式、明显截断、裸 VAD 页面、未知导出边界或未处理的强加壳对象。先用 DiE、PEStudio、HxD、FLOSS/capa 和内存上下文确认对象可比性。

## 使用方法

### 1. 生成一致的分析输入

1. 分别在同版本 IDA 中导入 Primary 与 Secondary 工作副本，确认处理器、位数、image base 和自动分析完成状态一致。
2. 为每个项目记录样本 SHA-256、IDA 版本、BinDiff 插件版本、数据库路径与导出时间。
3. 使用 BinDiff/ BinExport 插件为两端生成对应导出物；Ghidra 路径则分别以同版本扩展手动导出 BinExport 文件。
4. 为所有 `.BinExport`、IDA/Ghidra 项目与原输入计算 SHA-256，保存为输入清单。

不要在导出前后修改函数、类型、注释或符号来“提高匹配率”。若要研究人工注释对结果的影响，应复制项目、单独编号并说明差异。

### 2. 建立 diff 与留档

在 IDA BinDiff 插件中打开主窗口（官方手册中为 `Ctrl+6`），选择 `Diff Database`/对应菜单，明确 Primary 与 Secondary 后开始比较。保存结果至 `04-BinDiff-结果\`，文件名包含两端短哈希与版本，例如：

```text
LAB-001_primary-a1b2c3d4_secondary-e5f6a7b8_BinDiff8.BinDiff
```

同时保存：启动参数/界面截图、BinDiff/IDA 版本、输入清单、匹配统计、结果 `.BinDiff` 哈希、过滤条件、人工确认的匹配及其理由。BinDiff 结果是派生 SQLite/数据库类结果，不能替代原始二进制或内存镜像。

### 3. 解读匹配结果

| 视图/指标 | 可以帮助回答 | 不可直接推出 | 必须复核 |
| --- | --- | --- | --- |
| Matched Functions | 哪些函数结构可能对应、哪些变化值得优先审阅 | 两文件必然同源或函数语义完全相同 | 函数图、指令、字符串、导入与原始字节 |
| Unmatched Functions | 哪些函数未形成自动匹配 | 函数一定新增、删除或恶意 | 导出完整性、加壳、分析器识别与架构 |
| Similarity / Confidence | 对审阅排序的参考 | 高分即真实匹配、低分即无关 | 匹配依据和人工审阅 |
| Flowgraph / Callgraph | 控制流和调用关系的差异位置 | 运行时调用已发生 | x64dbg/API Monitor/Procmon 与镜像线程/VAD |

优先人工查看：高置信但低相似度的匹配、与线程入口/RVA 相邻的差异、未匹配的可执行函数、涉及字符串/导入变化的函数。记录每次人工确认或拒绝匹配的理由，不删除“不符合预期”的结果。

### 4. 注释与符号迁移边界

BinDiff 支持从另一数据库导入符号/注释，但官方手册警告当前数据库中的局部变量名等可能被覆盖。取证流程默认**不在主项目执行导入**；如教学需要，先复制目标数据库，在副本上操作并记录来源、范围、前后哈希和覆盖风险。迁移的名称/注释属于分析假设，不能回写为原始样本事实。

## 与内存取证的联合分析

### 场景一：磁盘参考文件与内存恢复 PE

1. Volatility 3/MemProcFS 从完整镜像导出来源明确、头部/节表可评估的候选 PE，记录 PID、VAD/文件对象、导出命令、镜像 SHA-256 和导出物哈希。
2. 选择同版本或已知参考磁盘文件作为 Primary，导出物作为 Secondary；通过 DiE/PEStudio/HxD 核对架构、PE 结构和截断情况。
3. 运行 BinDiff，优先检查线程起始地址附近函数、模块映射差异和未匹配函数。
4. 将 BinDiff 静态 RVA 换算为运行时 VA：`运行时 VA = 内存模块基址 + RVA`；用 VAD、线程、模块和原始字节确认对象关系。

### 场景二：受控版本差异与内存行为解释

1. 对两份授权、良性版本文件固定哈希和静态项目，使用 BinDiff 识别变化函数。
2. 在隔离实验中运行其中一个版本，使用 TaskExplorer/x64dbg/API Monitor 只读记录相关模块/线程地址，再采集 RAM 镜像。
3. 以 RVA 对齐 BinDiff 差异函数和镜像中模块/线程/VAD；网络、文件或注册表行为仍需独立日志证明。
4. 报告格式：`BinDiff 指出 <函数/RVA> 结构差异；该地址在 <镜像/PID/线程> 中被确认/未确认；行为证据来自 <日志>。`

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| IDA 插件不可用 | 核对 BinDiff 8、IDA 版本/路径和安装日志；不从第三方下载 DLL 覆盖插件 |
| 匹配很少或为空 | 检查架构、加壳、截断、反汇编器配置和 BinExport 是否来自完整分析；保留结果，不强行调阈值 |
| 高相似度但人工看起来不同 | 查看匹配依据、函数图和原始字节；相似度不是语义等价证明 |
| Ghidra 导出失败 | 记录 Ghidra/扩展版本与加载器配置；回退到 IDA 或不作 BinDiff 结论 |
| 注释迁移覆盖现有信息 | 仅在项目副本中执行，恢复主项目并记录影响范围 |

## 实战检查清单

- [ ] BinDiff、IDA/Ghidra、BinExport 版本和插件状态均已固定并记录。
- [ ] Primary/Secondary 方向明确，二进制与 BinExport 输入均已哈希且来源可追溯。
- [ ] 已排除架构不符、明显截断、裸 VAD 页和未处理加壳对象的直接 diff。
- [ ] 已保存 `.BinDiff`、匹配统计、过滤条件、人工确认理由和结果哈希。
- [ ] 相似度/置信度只用于排序，关键函数已用原始字节、模块/VAD、线程和动态证据复核。
- [ ] 未在主项目导入/迁移符号或注释，未覆盖原始分析记录。

## 官方资料

- [Zynamics BinDiff Manual](https://www.zynamics.com/bindiff/manual/)
- [BinDiff 官方页面](https://www.zynamics.com/bindiff.html)
- [google/bindiff 开源仓库](https://github.com/google/bindiff)
