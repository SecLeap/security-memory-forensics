# Exeinfo PE 实战手册

> 适用范围：隔离分析机中，对授权二进制工作副本和来源明确的内存导出物进行格式、编译器、壳/压缩与结构线索初筛。Exeinfo PE 不执行样本，也不替代 PEStudio、DiE、HxD 或内存镜像对象分析。

[Exeinfo PE](https://github.com/ExeinfoASL/Exeinfo) 主要提供可执行文件、壳/压缩器和部分归档格式的识别线索。其“unpack info”和内部解压相关功能不属于本仓库流程：只读取识别结果，**不使用内置解包、按键解压、下载器、PUP/PUA 组件或第三方扩展**。

## 获取与安装

1. 仅从维护者的 [GitHub Releases](https://github.com/ExeinfoASL/Exeinfo/releases) 获取发布包，保留原始包至 `C:\Lab\Installers\ExeinfoPE\`；避免第三方下载站、汉化整合包和未知“破解版”。
2. 解压/部署到隔离分析 VM 的 `C:\Lab\Tools\ExeinfoPE\`，记录发布标签、下载 URL、文件 SHA-256、许可证、签名状态（如有）和 VM 快照。
3. 用已知良性 PE 副本验证可启动和读取结果；不要通过双击未知样本或启用内部工具验证安装。

```powershell
Get-FileHash 'C:\Lab\Installers\ExeinfoPE\<发布包>' -Algorithm SHA256
Get-ChildItem 'C:\Lab\Tools\ExeinfoPE' -Recurse -File | Get-FileHash -Algorithm SHA256
```

Exeinfo PE 版本、签名库和识别规则会影响结果。案例期间冻结工具/规则版本，并在报告中将其标记为“工具提示”。

## 证据准备与使用方法

```text
C:\Lab\Cases\LAB-001\
├─ 00-原始文件\
├─ 01-工作副本\
└─ 02-静态识别\ExeinfoPE\
```

1. 对原件和工作副本计算 SHA-256；只将工作副本拖入或通过 Exeinfo PE 的打开功能选择。
2. 记录文件格式、架构、编译器/运行时、壳/保护/压缩提示、入口点、节/熵类提示及错误/未知状态。
3. 截图需包含工具版本、输入文件名/短哈希与结果；在同目录保存手工记录，不以单个壳名称作为结论。
4. 不执行 `x` 等可能解压归档的交互，不提取内嵌文件，不把工具显示的“可解包”说明视为已解包证据。

推荐记录模板：

```text
对象：<工作副本>；SHA-256：<hash>
来源：<磁盘原件 / Volatility 导出 / MemProcFS VFS 路径>
Exeinfo PE：<版本/规则>；时间：<UTC>
提示：<格式、架构、编译器、壳/保护、入口/节>
复核：<PEStudio/DiE/HxD/Ghidra/Volatility VAD>
结论边界：工具提示，已验证/待验证/不支持。
```

## 结果复核与内存取证联动

| Exeinfo PE 线索 | 必须复核 | 结论边界 |
| --- | --- | --- |
| PE/ELF/Mach-O/归档类型 | HxD 文件头、DiE/PEStudio 结构 | 格式需以原始字节确认 |
| 编译器/运行时提示 | 导入、Rich/调试信息、字符串、Ghidra | 支持“特征一致”，非确证归因 |
| 壳/保护/压缩提示 | 节表、熵、入口点、原始字节和导出完整性 | 可能误报/漏报，不等于恶意 |
| Unknown/错误 | 文件大小、头部、VAD 导出边界 | 可能为截断/裸页/新格式，非无害结论 |

对来自内存镜像的对象：先在 Volatility 3/MemProcFS 中记录 PID、VAD/文件对象、导出命令、镜像 SHA-256 和导出物哈希；再用 Exeinfo PE 初筛。若工具提示与内存模块/VAD 不符，保留差异并检查 ASLR、重定位、截断、手工映射和采集时间。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 安全软件告警 | 重新核验官方来源/哈希；仅在隔离 VM 评估，不设置生产永久排除项 |
| 壳/编译器结果冲突 | 固定版本后用 DiE、PEStudio、HxD 和 Ghidra 交叉验证，记录冲突 |
| 试图使用内部解包功能 | 停止；本手册不允许该操作，保留原始副本并按静态/镜像流程验证 |
| 无法识别导出物 | 检查头部和导出边界，保留 `Unknown` 与来源信息，不伪造文件头 |

## 实战检查清单

- [ ] 已记录官方来源、工具/规则版本、SHA-256 与 VM 快照。
- [ ] 仅处理工作副本，原件与导出物来源/哈希完整。
- [ ] 未使用内置解包、下载、提取或其他会改变对象的功能。
- [ ] 所有壳/编译器提示均已用结构、原始字节和内存上下文复核。

## 官方资料

- [Exeinfo PE 官方仓库](https://github.com/ExeinfoASL/Exeinfo)
- [Exeinfo PE Releases](https://github.com/ExeinfoASL/Exeinfo/releases)
