# Ghidra 实战手册

> 适用范围：离线分析机中对授权二进制工作副本进行静态反汇编、反编译、字符串/Xref 和地址注释。Ghidra 不执行样本，也不直接替代对 WinPmem RAW 镜像的对象解析。

[Ghidra](https://github.com/NationalSecurityAgency/ghidra) 是开源软件逆向框架。官方预构建发行包需要 64 位 JDK 21；下载官方发布 ZIP（不是 GitHub 自动生成的 Source Code ZIP），解压到新目录后用 `ghidraRun.bat` 启动。版本、JDK、扩展和分析选项都会影响项目结果。

## 获取与安装

1. 从 [官方 Releases](https://github.com/NationalSecurityAgency/ghidra/releases) 获取预构建 `ghidra_<版本>_<日期>.zip`，记录发布标签、官方 SHA-256、下载 URL 和文件 SHA-256。
2. 安装/验证 64 位 JDK 21，记录发行商、版本和路径；不要依赖系统中未知的 Java 版本。
3. 将每个 Ghidra 版本解压到独立目录，例如 `C:\Lab\Tools\ghidra_12.1\`；官方明确建议不要覆盖既有安装。
4. 启动 `ghidraRun.bat`，用良性样本建立本地项目并检查 CodeBrowser、Decompiler、Listing、Memory Map 和 Strings 视图。

```powershell
Get-FileHash 'C:\Lab\Installers\Ghidra\ghidra_<版本>.zip' -Algorithm SHA256
java -version
Start-Process -FilePath 'C:\Lab\Tools\ghidra_<版本>\ghidraRun.bat'
```

仅安装官方或已审核、且与当前 Ghidra 版本严格匹配的扩展。案例期间禁用自动更新、未知脚本和不受控的远程协作/共享项目功能。

## 案例项目与输入固定

```text
C:\Lab\Cases\LAB-001\
├─ 00-原始文件\
├─ 01-工作副本\
├─ 02-Ghidra-项目\
├─ 03-静态分析笔记\
└─ 04-内存镜像与输出\
```

原件只读保存，Ghidra 仅导入工作副本。项目名包含案例号、样本短哈希和 Ghidra 版本；记录样本 SHA-256、导入时间、语言/编译器规范、image base、自动分析器清单和扩展版本。项目数据库、导出报告和截图均为派生物，需要单独哈希与访问控制。

## 使用方法

### 1. 导入与自动分析

1. `File > Import File` 导入工作副本，确认路径和 SHA-256。
2. 审核 Ghidra 的 language/compiler specification、位数、字节序和 image base；不确定时用 DiE、PEStudio、HxD 复核文件头与架构。
3. 在 Auto Analysis 窗口保留默认最小集合或按案例记录的配置运行；保存开始/结束时间、警告和未解析区域。
4. 对 PE、ELF、Mach-O 或裸导出物分别记录加载器选择和边界；格式不完整时不要伪造头部以获得更多函数。

### 2. 静态审阅顺序

| 视图 | 目标 | 必留记录 |
| --- | --- | --- |
| Program Trees / Memory Map | 段、节、权限、image base 与加载范围 | 地址范围、权限、文件偏移对应关系 |
| Symbol Tree / Functions | 函数入口、外部符号、导入/导出 | 函数地址、命名依据、调用关系 |
| Defined Strings / Xrefs | 字符串、编码、引用者 | 静态地址、引用函数、原始字节位置 |
| Listing / Graph | 指令与控制流 | 关键块地址、分支/调用、注释 |
| Decompiler | 高层辅助解释 | 伪代码截图、类型/变量重命名依据、局限 |

反编译伪代码是可读性辅助，不能替代汇编和原始字节。重命名、注释和数据类型都应标明来源（静态推断、动态观察或镜像验证）。

### 3. 地址对齐与项目导出

对模块内地址使用：

```text
RVA = Ghidra 静态地址 - Ghidra image base
运行时 VA = Volatility/MemProcFS/x64dbg 模块基址 + RVA
```

导出函数列表、注释或截图前，保存项目状态并记录导出范围、Ghidra/JDK 版本和输入哈希。不要将项目、二进制或反编译输出上传至公共协作服务器、在线反编译器或未知扩展。

## 与内存取证的联合分析

### 场景一：线程入口定位

1. Volatility 3/MemProcFS 记录 PID、线程起始地址、模块基址与 VAD 范围。
2. 将运行时 VA 换算为 RVA，在 Ghidra 中定位对应函数/基本块和相邻字符串。
3. 用 HxD、PEStudio/DiE 验证静态文件的段/节和字节；用 x64dbg（仅受控调试）补充运行时观察。
4. 若地址不属于已知模块或导出物无完整头部，记录范围和不确定性，以 VAD/线程/原始字节为主。

### 场景二：字符串与受控网络证据

1. Ghidra 中定位静态字符串及 Xref，记录函数 RVA 和字节。
2. FLOSS/PEStudio 交叉确认字符串编码和文件偏移，capa 提供能力规则线索。
3. 使用 Fiddler/Wireshark/FakeNet 或 Debian 服务日志验证同时间的实际通信，并在镜像中复核 PID/socket/VAD。
4. 字符串仅作为候选 IOC；没有独立网络/内存对象证据时不描述为已执行通信。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 启动失败 | 核对官方发行包、JDK 21 x64、解压目录和 Ghidra 版本；不要覆盖旧安装 |
| 语言/编译器规格错误 | 回到 DiE、PEStudio、HxD 和文件来源确认架构/格式，再重新导入工作副本 |
| 自动分析耗时或不完整 | 记录版本、分析器配置、输入大小/完整性和警告；不把未识别函数当作无恶意代码 |
| 地址与镜像不一致 | 区分 Ghidra 静态地址、RVA、运行时 VA，核对 image base、ASLR、模块版本和采集时间 |
| 扩展/脚本异常 | 禁用并记录；只安装经审核且版本匹配的扩展，不加载来源不明脚本 |

## 实战检查清单

- [ ] 使用官方预构建发行包与 JDK 21 x64，已记录版本和 SHA-256。
- [ ] 仅导入工作副本，项目名、输入哈希、架构、image base 和分析器配置均已记录。
- [ ] 静态推断、动态观察和镜像验证在注释/报告中明确分层。
- [ ] 关键函数/字符串地址已以 RVA 与 Volatility 3/MemProcFS 的运行时模块基址对齐。
- [ ] 未使用未知扩展、脚本、在线协作或公共反编译服务。

## 官方资料

- [Ghidra 官方项目](https://github.com/NationalSecurityAgency/ghidra)
- [Ghidra Releases](https://github.com/NationalSecurityAgency/ghidra/releases)
- [Ghidra Getting Started](https://github.com/NationalSecurityAgency/ghidra/blob/master/GhidraDocs/GettingStarted.md)
