# PE-bear 0.7.2 实战手册

> 适用范围：隔离 Windows 11 分析虚拟机中，对授权 PE 工作副本和来源明确的内存导出物做只读结构审阅。PE-bear 不执行样本；PE 结构异常是待解释证据，不单独等同于注入、壳或恶意行为。

[PE-bear](https://github.com/hasherezade/pe-bear) 是面向 PE 文件的静态查看工具，适合将头部、节表、数据目录、导入/导出、资源和原始十六进制视图关联起来。用户保存的 PE-bear_0.7.2_qt6_x64_win_vs22.zip 应与官方发布标签、发布包哈希/签名（如有）核验后使用。

## 获取与安装

1. 从 [官方 Releases](https://github.com/hasherezade/pe-bear/releases) 获取与系统架构匹配的发布包，或对用户已保存的 0.7.2 压缩包记录下载 URL、标签、文件名和 SHA-256。
2. 原始包留在 C:\Lab\Installers\PE-bear\，解压到 C:\Lab\Tools\PE-bear-0.7.2\；这是便携工具，无需将 DLL 复制到系统目录。
3. 在快照后的隔离 VM 中，使用已知良性 PE 工作副本确认能显示结构视图；不要以未知样本双击方式验证。

    Get-FileHash 'C:\Lab\Installers\PE-bear\PE-bear_0.7.2_qt6_x64_win_vs22.zip' -Algorithm SHA256
    Get-ChildItem 'C:\Lab\Tools\PE-bear-0.7.2' -Recurse -File | Get-FileHash -Algorithm SHA256

记录 PE-bear 版本、主程序哈希、系统架构和案例期间使用的界面版本。不要安装非官方主题、插件或“修复/重打包”扩展。

## 输入与输出约定

    C:\Lab\Cases\LAB-001\
    ├─ 00-原始文件\
    ├─ 01-工作副本\
    ├─ 03-静态识别\PE-bear\         # 截图、字段表、导出视图
    └─ 04-内存镜像与输出\            # 镜像及 Volatility/MemProcFS 导出物

只将工作副本或来源已记录的导出物载入 PE-bear。每份记录包含输入 SHA-256、输入来源、PE-bear 版本、观察时间和所见字段；截图应包括窗口标题/文件名与关键字段。不要保存修改后的 PE 覆盖原始副本。

## 使用方法

### 1. 初始完整性检查

1. 在 PE-bear 中通过 Open 打开工作副本，确认文件名与短哈希。
2. 查看 DOS/NT 头，记录 MZ、PE 签名、Machine、PE32/PE32+、ImageBase、AddressOfEntryPoint、SizeOfImage 与时间戳字段。
3. 检查节表：节名、RVA、Raw offset、VirtualSize、RawSize、特征和节间重叠/越界提示。
4. 记录解析错误、异常数据目录或“无法映射”提示。它们可能来自截断、故意构造、内存重建差异或工具解析差异，不能跳过或自动修正。

### 2. 结构化审阅

| 视图 | 建议记录 | 必须避免的过度结论 |
| --- | --- | --- |
| Data Directories | Import、Export、Resource、TLS、Load Config、Security、Relocation 是否存在及 RVA/大小 | 某目录存在不代表运行时使用 |
| Imports/Exports | DLL/函数、序号导入、延迟导入、异常/空表 | 导入函数不等于函数已调用 |
| Resources | 类型、名称、语言、大小和原始偏移 | 嵌入对象不等于已释放或执行 |
| TLS / Load Config | 回调地址、Guard/CFG、异常字段 | 字段异常需同原始字节和映像布局复核 |
| Hex view | MZ、PE 签名、RVA/offset 对应字节 | 只查看，不修改工作副本 |

将“字段值”“解释假设”“复核证据”分列。例如入口点字段是事实；“入口点异常”是待验证判断；是否执行须靠线程、模块和时间线验证。

### 3. 内存导出物中的 PE

1. 先在 Volatility 3/MemProcFS 中保留完整内存镜像哈希、导出命令、PID、VAD/文件对象、地址范围、权限和导出物 SHA-256。
2. 用 PE-bear 查看导出物的头、节、数据目录和映像大小，并记录导出物是否缺页、是否存在重定位/映射差异。
3. 将 PE 的 ImageBase、入口点和节 RVA 换算到对应的内存基址；用线程起始地址、VAD、模块列表和原始字节复核，注意 ASLR 与重定位。
4. 磁盘副本与内存导出物均要独立留档。哈希不同并不自动证明篡改：导出边界、重定位、内存补丁、版本差异和采集时间都需要排查。

## 场景组合

| 目标 | 组合路径 | 交付物 |
| --- | --- | --- |
| 安装包提取的载荷初筛 | InnoExtractor/InnoUnpacker → PE-bear → DiE/PEStudio → FLOSS | 提取链、PE 字段表、静态输出和对象哈希 |
| 可疑内存映像 | Volatility 3/MemProcFS → 导出物 → PE-bear → HxD/DiE | 镜像来源、VAD/模块上下文、结构异常及字节复核 |
| 动态行为解释 | PE-bear 导入/资源线索 → Procmon/Noriben、PCAP → 内存对象 | 明确区分静态能力线索与已观察行为 |

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 文件打不开/字段异常 | 记录输入哈希与错误，检查文件头、大小、导出边界；不伪造头部或用“修复”覆盖副本 |
| RVA 无法映射到 Raw offset | 记录节表与该字段，检查节大小、对齐、截断或内存映射差异 |
| 与其他工具的导入/节结果不同 | 固定同一输入哈希与版本；用 HxD 原始字节和 PE 规范字段交叉复核 |
| 安全软件告警工具包 | 重新从官方发布核验；仅隔离环境记录告警，不添加生产永久排除 |

## 实战检查清单

- [ ] 已核验官方发布包/工具主程序和输入对象 SHA-256。
- [ ] 只打开工作副本或有来源记录的内存导出物。
- [ ] 已记录头、节表、数据目录和每项关键异常的原始字节/偏移。
- [ ] 已将 PE 静态字段与运行时线程、VAD、模块和采集时间分开描述。
- [ ] 未执行、修补、重打包或覆盖任何原件。

## 官方资料

- [PE-bear 官方项目](https://github.com/hasherezade/pe-bear)
- [PE-bear 官方 Releases](https://github.com/hasherezade/pe-bear/releases)
