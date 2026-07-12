# WinDbg X64 10.0.26100.6584 实战手册

> 适用范围：离线分析机上对 Windows crash dump、进程 minidump、受控调试转储和符号/地址进行只读分析。WinDbg 不能直接替代对 WinPmem RAW 镜像的解析；RAW 镜像的对象取证以 Volatility 3 和 MemProcFS 为主。

本手册针对用户指定的 `WinDbg_X64_v10.0.26100.6584`。该版本须以安装包自身属性、`windbg -version`（如可用）和安装来源核验；不要因版本号相近而替换为未知的第三方调试器。Microsoft 将现代 WinDbg 与 Debugging Tools for Windows 区分管理，且符号路径和版本会直接影响结论可复现性。

## 获取、校验与符号隔离

1. 从 [Microsoft WinDbg 安装页](https://learn.microsoft.com/windows-hardware/drivers/debugger/) 或组织已批准的软件源获取指定安装包；保存原件、URL、版本、签名和 SHA-256。
2. 在隔离分析 VM 安装，不在案例期间自动升级；记录实际安装路径与 `10.0.26100.6584` 的核验截图/命令输出。
3. 符号缓存放在案例外、可审计的独立目录，例如 `C:\Lab\Symbols\Microsoft\`；不要混入样本、私有 PDB 或下载文件。

```powershell
Get-FileHash 'C:\Lab\Installers\WinDbg\WinDbg_X64_v10.0.26100.6584.exe' -Algorithm SHA256
Get-AuthenticodeSignature 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\windbg.exe' |
  Format-List Status,StatusMessage,SignerCertificate
```

离线案例默认不联网下载符号。若确需微软公共符号，先在获批准的联网准备机下载到专用缓存，记录下载时间、符号路径和网络边界，再将缓存副本与清单带入分析机。

## 符号路径与最小验证

Microsoft 文档建议用 `.symfix` 设置默认公共符号路径，并支持把符号缓存到本地。对受控联网准备机可使用：

```text
.symfix C:\Lab\Symbols\Microsoft
.sympath srv*C:\Lab\Symbols\Microsoft*https://msdl.microsoft.com/download/symbols
.reload /f
lm
```

在离线分析机改为只指向已导入的本地缓存，例如：

```text
.sympath C:\Lab\Symbols\Private;C:\Lab\Symbols\Microsoft
.reload /f
lm
```

记录完整符号路径、`lm` 输出、缺失/不匹配符号和 dump SHA-256。符号不足时应将结果标记为受限，不下载不明 PDB 或猜测结构偏移。

## 只读 dump 分析流程

### 1. 证据准备

```text
C:\Lab\Cases\LAB-001\
├─ 00-原始转储\
├─ 01-工作副本\
├─ 02-WinDbg-输出\
└─ 03-Volatility3-输出\
```

对原始 dump、工作副本和每份 WinDbg 文本输出计算 SHA-256。将 dump 类型、来源、PID（如适用）、生成工具、创建时间、架构和完整性限制写入记录。不要对 dump 执行写内存、保存修改、加载未知扩展或把 dump 上传到在线服务。

### 2. 打开与基础命令

用 GUI 的 `File > Open Dump File` 或命令行 `windbg.exe -z <dump路径>` 打开工作副本。常用的只读检查命令：

```text
vertarget
lm
!address -summary
~* k
!analyze -v        ; 仅适用于 crash dump，保留完整输出
```

`vertarget` 记录目标/调试器上下文，`lm` 显示模块及符号状态，`!address -summary` 给出地址空间摘要，`~* k` 记录线程栈，`!analyze -v` 仅作崩溃分析线索。所有命令、输出文件、执行时间与符号路径都应留档。不得使用写内存、修改寄存器、继续执行、内核实时调试或未知扩展命令。

### 3. 地址与模块复核

| WinDbg 信息 | 与内存取证的关系 | 复核要点 |
| --- | --- | --- |
| 模块基址/大小 | 与 Volatility 模块、VAD 及 MemProcFS 映射对齐 | 区分 VA、RVA、文件偏移与 ASLR |
| 线程栈/当前地址 | 与线程对象、起始地址、可执行 VAD 对齐 | 记录 dump 时间和符号状态，不把失败栈当事实 |
| 地址空间摘要 | 辅助解释私有/映射区域 | 以 VAD/原始字节和模块关系确认 |
| 崩溃分析 | 解释异常终止线索 | 只适用于合适 dump，不能推断完整执行历史 |

## 与 RAW 镜像取证的联合分析

1. 先在 Volatility 3/MemProcFS 中从 WinPmem RAW 镜像记录 PID、命令行、模块、VAD、线程和对象来源。
2. 如有同时间或同进程的 minidump/crash dump，单独以 WinDbg 打开并记录模块基址、地址空间和栈线索。
3. 通过 PID、时间、模块路径/哈希、基址和 RVA 建立关联；dump 与全量镜像不同步时必须声明时间差和覆盖范围差异。
4. 用 Ghidra/x64dbg/HxD 对静态或调试派生物解释地址，最终以完整 RAM 镜像的对象关系为取证主线。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 符号未加载或错误 | 核对 dump/模块版本、符号路径和缓存来源；记录限制，不下载未知 PDB |
| `!analyze -v` 无有效结论 | 确认 dump 类型与覆盖范围；保留输出，转向线程/模块/VAD 的独立取证 |
| 地址与 Volatility 不一致 | 区分 dump 时间、ASLR、模块版本、VA/RVA/文件偏移和符号状态 |
| 想打开 WinPmem RAW | 不将 RAW 直接作为 WinDbg dump；先用 Volatility 3/MemProcFS 解析并导出可验证对象 |
| 调试器请求联网符号 | 在离线案例中拒绝自动联网，使用已批准的本地缓存或记录“符号受限” |

## 实战检查清单

- [ ] 已核验 `10.0.26100.6584` 安装包、可执行文件、来源和签名/哈希。
- [ ] dump、输出、符号路径和缓存来源均已记录并计算必要哈希。
- [ ] 仅执行只读 dump/符号/地址查询，未进行实时内核调试、写内存或未知扩展加载。
- [ ] RAW 镜像主分析仍由 Volatility 3/MemProcFS 执行，WinDbg 结果已标注 dump 范围和时间边界。

## 官方资料

- [Microsoft WinDbg 安装文档](https://learn.microsoft.com/windows-hardware/drivers/debugger/)
- [Microsoft 符号路径文档](https://learn.microsoft.com/windows-hardware/drivers/debugger/symbol-path)
