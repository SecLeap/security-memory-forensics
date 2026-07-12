# MiTeC EXE Explorer 3.7.5 实战手册

> 适用范围：隔离分析机中，对 PE32、PE32+、NE、VxD、.NET 等可执行文件工作副本进行结构读取、资源/证书/CLR 元数据检查和文本报告留档。MiTeC EXE Explorer 不执行样本，不能替代内存镜像解析或动态行为证据。

[MiTeC EXE Explorer 3.7.5](https://www.mitec.cz/wp/mee/) 可显示 DOS/File/Optional/Rich/CLR 头、节、目录、导入导出、资源、字符串、Load Config、TLS、异常、证书、版本信息和十六进制视图，并可生成文本报告。3.7.5 增加 ARM64/EC 与新编译器检测；该类识别均为静态线索，必须用原始字节与内存上下文复核。

## 获取与安装

1. 从 [MiTeC 官方 EXE Explorer 页面](https://www.mitec.cz/wp/mee/) 获取 3.7.5，保存下载包到 `C:\Lab\Installers\MiTeC-EXE-Explorer\`；不使用第三方重打包。
2. EXE Explorer 3.7.5 的产品许可状态以官方页面当前条款为准；在商业/组织环境使用前确认授权，不将注册信息/订单信息保存进案例。
3. 在隔离分析 VM 解压/安装至 `C:\Lab\Tools\MiTeC-EXE-Explorer-3.7.5\`，记录下载 URL、版本、SHA-256、签名状态（如有）和 VM 快照。

```powershell
Get-FileHash 'C:\Lab\Installers\MiTeC-EXE-Explorer\<发布包>' -Algorithm SHA256
Get-ChildItem 'C:\Lab\Tools\MiTeC-EXE-Explorer-3.7.5' -Recurse -File | Get-FileHash -Algorithm SHA256
```

用已知良性 PE 验证启动、打开、文本报告导出和关闭流程。若工具提供 VirusTotal/API 查询，默认禁用；受限样本的哈希、字符串和元数据也不应未经授权外发。

## 证据准备与报告目录

```text
C:\Lab\Cases\LAB-001\
├─ 00-原始文件\
├─ 01-工作副本\
└─ 02-静态识别\MiTeC-EXE-Explorer\
   ├─ 报告\
   ├─ 截图\
   └─ 哈希与笔记\
```

原始文件和内存导出物只读保管，EXE Explorer 只打开工作副本。每次报告记录输入 SHA-256、工具版本、打开时间、来源和导出报告文件 SHA-256。

## 使用方法

### 1. 结构化初筛

1. 用 `File > Open`（或等效打开方式）选择工作副本，确认文件路径和短哈希。
2. 先记录可执行类型、架构、入口点、image base、子系统、时间戳、签名/证书状态、版本信息和编译器/保护提示。
3. 依次检查 Headers、Sections、Directories、Imports/Exports、Resources、Strings、Load Config、TLS、Exceptions、Debug 与 CLR/.NET 元数据（如适用）。
4. 对资源、类型库或文本预览只做查看/报告导出；不保存/重写资源、不使用生成接口代码等会产生额外派生代码的功能。
5. 导出文本报告至案例目录，保留原始报告与截图；筛选后的摘录另存，不能覆盖原始报告。

### 2. 重点字段与复核路径

| EXE Explorer 页面/字段 | 记录目的 | 必须复核 |
| --- | --- | --- |
| Headers / Rich / CLR | 架构、入口、.NET、构建线索 | HxD 原始头部、PEStudio/DiE |
| Sections / Directories | 节权限、大小、目录完整性、overlay 线索 | HxD 偏移、PEStudio、内存 VAD/映射 |
| Imports / Exports | 潜在依赖、函数入口和库信息 | Ghidra/IDA、capa、运行时模块/线程 |
| Resources / Version / Certificates | 嵌入内容、版本矛盾、签名线索 | 原始资源字节、证书链/文件来源 |
| Strings / .NET Metadata | 路径、域名、类/程序集线索 | FLOSS、HxD、PCAP/服务日志与内存对象 |
| Load Config / TLS / Exceptions / Debug | 保护/加载/异常处理和构建线索 | 原始字节、Ghidra/IDA、线程/VAD 上下文 |

编译器、安装器、壳/保护器和 VirusTotal 显示结果均是辅助线索。合格表述：`MiTeC EXE Explorer 3.7.5 提示 <…>；已由 <原始字节/PEStudio/内存证据> 支持/尚待验证。`

### 3. 与内存取证的联合分析

1. 对 Volatility 3/MemProcFS 导出物先记录完整镜像哈希、PID、VAD/文件对象、导出方法和导出物哈希。
2. EXE Explorer 验证该导出物是否是完整 PE/.NET 对象，记录头部、节表、目录和资源完整性。
3. 将静态 image base/RVA 与运行时模块基址换算：`运行时 VA = 模块基址 + RVA`；用线程起始地址、VAD 权限和模块映射复核。
4. 对字符串/导入/资源线索，使用 FLOSS、Ghidra/IDA、Procmon、PCAP 或服务端日志形成独立验证链。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 打不开/解析不完整 | 检查文件头、大小、架构和内存导出边界；保留错误结果，不伪造头部 |
| 报告字段与其他工具不同 | 比较输入 SHA-256、工具版本、文件偏移/RVA 与解析范围；记录冲突并以原始字节复核 |
| VirusTotal/API 查询提示 | 默认关闭；仅在授权范围内使用并记录外发内容、时间和查询状态 |
| 资源/文本很可疑 | 导出为派生副本并计算哈希，不执行、不打开为活动内容，回到来源对象验证 |

## 实战检查清单

- [ ] 已记录 3.7.5 官方下载、许可适用性、工具/输入 SHA-256 与 VM 快照。
- [ ] 仅打开工作副本，未执行资源重写、代码生成或在线查询。
- [ ] 已保留原始文本报告、截图、字段偏移/RVA 和来源链。
- [ ] 静态识别结果已与 HxD、PEStudio/DiE、Ghidra/IDA 和内存对象交叉验证。

## 官方资料

- [MiTeC EXE Explorer 官方页面](https://www.mitec.cz/wp/mee/)
- [MiTeC 应用与工具目录](https://www.mitec.cz/wp/apps/)
