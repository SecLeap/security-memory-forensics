# CFF Explorer 实战手册

> 适用范围：隔离 Windows 11 分析虚拟机中，对已授权的 PE 工作副本和来源明确的内存导出物进行只读结构审阅。CFF Explorer 具备编辑、重建、导入修复与脚本能力；本仓库仅使用其查看功能，**不修改、不修复、不重建、不执行脚本**。

[CFF Explorer / Explorer Suite](https://ntcore.com/explorer-suite/) 由 NTCore 提供，支持 PE32/PE32+、.NET 内部结构、资源、十六进制、数据目录、依赖与报告等视图。官方页面显示 Explorer Suite III 为较旧版本，且 NTCore 已提示存在冒充下载域名；因此只可从 ntcore.com 或经核验的内部软件库获取，并把它作为兼容性辅助工具，使用 PE-bear、PEStudio、DiE 和原始字节进行交叉验证。

## 获取与安装

1. 从 NTCore 官方 Explorer Suite 页面获取发布包；不访问搜索结果中的同名独立域名，不使用网盘、整合包、破解包或来源不明的单文件 CFF Explorer。
2. 保存原始压缩包/安装包至 C:\Lab\Installers\CFFExplorer\，记录下载 URL、页面显示的版本、发布日期、许可证、发布页校验值（如有）、下载时间和本地 SHA-256。
3. 在隔离 VM 解压或安装至 C:\Lab\Tools\CFFExplorer\；安装前后均创建 VM 快照。不要覆盖旧版、向系统目录复制组件或安装扩展。
4. 对实际 CFF Explorer 主程序及同目录关键依赖计算 SHA-256；在无害 PE 工作副本上确认可打开文件、切换只读查看和导出报告。

    Get-FileHash 'C:\Lab\Installers\CFFExplorer\<发布包>' -Algorithm SHA256
    Get-ChildItem 'C:\Lab\Tools\CFFExplorer' -Recurse -File | Get-FileHash -Algorithm SHA256

由于工具与 PE 解析生态较旧，未知/畸形 PE 可能导致崩溃或错误解析。仅在断网、快照后的分析 VM 使用；解析失败本身是待记录现象，不得借助“修复”“重建”来强行使文件可读。

## 使用前的证据准备

    C:\Lab\Cases\LAB-001\
    ├─ 00-原始文件\                  # 原始磁盘对象，只读
    ├─ 01-工作副本\                  # CFF Explorer 输入
    ├─ 03-静态识别\CFFExplorer\
    │  ├─ LAB-001-字段记录.md
    │  ├─ LAB-001-截图\
    │  └─ LAB-001-报告\
    └─ 04-内存镜像与输出\

每个输入对象记录：案例号、来源、完整路径、SHA-256、大小、CFF Explorer 版本/主程序 SHA-256、打开时间和操作者。内存导出物还必须附完整镜像 SHA-256、Volatility 3/MemProcFS 导出命令、PID、VAD/文件对象、地址范围、页面权限和导出时间。

输入始终是工作副本或有完整来源链的导出物。关闭自动保存、编辑/重建、扩展和脚本功能；界面若提示保存更改，选择“不保存”。

## 使用方法

### 1. 初始结构与完整性检查

1. 从 CFF Explorer 的打开功能选择工作副本；不要通过资源管理器双击样本，也不要启用“打开方式”关联。
2. 查看 DOS Header、NT Headers、Optional Header 和 File Header，记录 Machine、PE32/PE32+、ImageBase、AddressOfEntryPoint、SizeOfImage、Subsystem、DLL Characteristics、时间戳字段和任何解析错误。
3. 打开 Section Headers，记录节名、Virtual Address、Virtual Size、Pointer to Raw Data、Size of Raw Data、Characteristics、节数量、重叠/越界/对齐异常。
4. 使用 Hex Editor 定位关键字段的原始偏移并截图或写入字段记录。CFF Explorer 显示的字段值应由原始字节或另一 PE 工具复核。

字段记录示例：

    输入：candidate.exe；SHA-256：<hash>
    CFF Explorer：<版本>；主程序 SHA-256：<hash>；时间：<UTC>
    File Header：Machine=<...>；Characteristics=<...>
    Optional Header：ImageBase=<...>；EntryPoint RVA=<...>；SizeOfImage=<...>
    节表：<节名、RVA、raw offset、大小、特征>
    异常/错误：<原始提示>
    复核：<PE-bear/HxD/DiE 结果>

### 2. 数据目录、导入与资源审阅

| 视图 | 记录内容 | 结论边界 |
| --- | --- | --- |
| Data Directories | Import、Export、Resource、Exception、Security、Relocation、TLS、Load Config 的 RVA 与大小 | 目录存在不等于加载器或程序使用该数据 |
| Import/Delay Import | DLL、函数/序号、延迟导入、空表或异常项 | 导入函数不等于已调用，空导入也不等于恶意 |
| Export | 名称、序号、RVA、转发信息 | 导出不等于被其他进程使用 |
| Resources | 类型、名称、语言、大小、RVA/raw offset | 内嵌对象不等于已释放、执行或写盘 |
| .NET 视图 | CLR Header、元数据流、程序集/模块表、Manifest 线索 | .NET 字段要结合原始元数据和运行时模块复核 |
| Security / Certificate | 目录是否存在、大小、签名相关字段与解析错误 | 有证书目录不等于签名有效或可信 |
| TLS / Load Config | 回调地址、Guard/CFG、异常字段 | 不说明回调已执行或绕过了安全机制 |

只记录和导出当前视图的文本/截图，不使用 Resource Editor 导出后直接打开资源；若必须将资源作为分析对象，先以受控“派生物”导出、计算哈希、记录源 PE 的 SHA-256 和资源路径，再按相应静态工具流程处理。

### 3. PE 完整性与交叉复核

1. 使用工具显示的 PE integrity checks 仅作待验证提示，保存原始提示/截图。
2. 对关键问题（节重叠、RVA 越界、导入异常、资源循环、头部截断）用 HxD 原始字节及 PE-bear、PEStudio、DiE 复核。
3. 两个工具的结果冲突时，记录所有版本、输入哈希、字段位置和冲突内容；不要选择性保留符合假设的一方。
4. 不使用 Rebuilder、Realigner、Import Adder、Reloc Remover、Image Base Changer、强名称移除、资源编辑、脚本、签名更新或修改保存。它们会产生不同于原件的对象，破坏本手册的证据链。

## 与内存取证的联合使用

### 场景一：磁盘 PE 与内存模块布局比较

1. 在 Volatility 3/MemProcFS 中保留完整内存镜像哈希以及进程 PID、命令行、模块、VAD、线程起始地址、地址范围和导出命令。
2. 分别对磁盘工作副本和内存导出物建立独立哈希、独立字段表；用 CFF Explorer 比较 Machine、ImageBase、SizeOfImage、入口点、节表和数据目录。
3. 将文件 RVA 换算到对应的模块基址，检查线程/VAD 是否落在相关范围内；考虑 ASLR、重定位、按需分页、导出截断和采集时点。
4. 只有文件结构、VAD/模块、线程与原始字节能互相支持时，才描述为“该 PE 映像与该进程内存范围相关”；不能由结构差异单独认定注入或篡改。

### 场景二：从安装包/容器派生出的 PE

1. 用 InnoExtractor、InnoUnpacker 或 pyinstxtractor-ng 从容器产生派生物时，记录完整层级：容器原件哈希 → 提取输入哈希 → PE 派生物哈希。
2. 用 CFF Explorer 审阅 PE 结构，保存字段记录、截图和错误信息。
3. 以 PE-bear、DiE、PEStudio、FLOSS 对结构、格式和字符串线索交叉验证。
4. 报告中将“安装包静态含有对象”与“内存中该对象已执行/加载”严格分开。

### 场景三：.NET 线索的静态—内存对齐

CFF Explorer 的 .NET 元数据视图可记录程序集、模块和 Manifest 线索。内存镜像中应另行查找相应进程、模块/VAD 与线程上下文；不要因为 CFF Explorer 能读取 .NET 元数据就推断 CLR 已加载或程序集已执行。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 工具无法启动或被安全软件拦截 | 核验 NTCore 官方来源和本地哈希；仅在隔离 VM 记录现象，不从第三方补 DLL 或设置生产永久排除 |
| 文件打开后崩溃/无响应 | 记录输入哈希、版本和时点，恢复 VM 快照；改用 PE-bear、PEStudio、DiE 或 HxD 复核 |
| 显示字段明显不合理 | 检查输入是否截断、文件/内存导出边界及原始字节；不使用重建功能“修复” |
| 与其他工具结果冲突 | 固定同一输入和工具版本，记录 RVA/raw offset；以原始字节和 PE 结构规则交叉复核 |
| 出现保存提示 | 选择不保存；若误保存，立即保留被改副本哈希，停止将其当作原始证据并从原件重新复制工作副本 |
| 想运行 CFF 脚本或使用编辑器 | 停止；本手册仅授权只读审阅，脚本/编辑/重建不属于内存取证分析流程 |

## 实战检查清单

- [ ] 已仅从 ntcore.com 或已核验内部软件库获取，并记录发布包与主程序 SHA-256。
- [ ] 已在断网、隔离、可回滚 VM 使用，并只打开工作副本或来源明确的导出物。
- [ ] 已记录 PE 头、节表、数据目录、关键原始偏移与解析错误。
- [ ] 已用 PE-bear、PEStudio、DiE 或 HxD 复核关键字段和异常。
- [ ] 已禁用/未使用编辑、重建、导入修复、资源修改、脚本、签名更新及保存更改。
- [ ] 内存对象已关联镜像哈希、导出命令、PID、VAD/文件对象、地址范围与采集时间。
- [ ] 结论明确区分静态结构线索、内存对象关联与已验证运行时事实。

## 官方资料

- [NTCore Explorer Suite / CFF Explorer](https://ntcore.com/explorer-suite/)
- [NTCore 关于冒充 CFF Explorer 域名的公告](https://ntcore.com/2025/)
