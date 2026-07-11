# CyberChef 实战手册

> 适用范围：隔离环境中，对来自工作副本、内存导出物或静态工具输出的字节/文本进行本地、可重放的编码识别、解码、格式转换、哈希与解析。CyberChef 输出是分析派生物，不是原始证据；解码出 URL、命令或脚本不等于它曾执行。

[GCHQ CyberChef](https://github.com/gchq/CyberChef) 是浏览器端数据转换工具。官方说明其处理在浏览器本地进行，并可下载本地副本；本仓库优先使用官方 release 的离线构建/本地页面，在断网 VM 打开。不得将案件字节、密钥、内存片段或 recipe URL 送入公共在线实例。

## 获取与安装

1. 从官方 GitHub Releases 获取固定版本，保存发布包至 C:\Lab\Installers\CyberChef\，记录标签、下载 URL、许可证、文件 SHA-256 和 VM 快照。
2. 解压到 C:\Lab\Tools\CyberChef\，在本地浏览器打开离线页面；浏览器禁止访问互联网，禁用同步/扩展，记录浏览器版本。
3. 用无害文本验证 Base64、From Hex、To Hex、SHA-256 等操作及 recipe 导出。开发构建、Docker 服务和 Node 方式属于部署/开发活动，不作为案例分析默认路径。

## 证据准备

    C:\Lab\Cases\LAB-001\03-静态识别\CyberChef\
    ├─ 00-输入副本\
    ├─ 01-recipe\
    ├─ 02-输出\
    └─ 03-记录\

每次处理记录输入来源（镜像 SHA-256、导出命令、PID、VAD/偏移或文件哈希）、输入字节范围/编码、CyberChef 版本、完整 recipe、所有参数、输出哈希、UTC 和操作者。大对象不要直接拖入浏览器；先提取最小必要字节副本并保留原始范围。

## 使用方法

### 1. 最小可重放 recipe

1. 复制/导入工作副本，先保存输入 SHA-256 和十六进制/文本的原始表示。
2. 每次只增加一个操作，例如 From Hex、From Base64、Gunzip、XOR、Strings、Parse JSON；观察输出变化后保存 recipe。
3. 输出应同时保留原始字节文件和可读文本（如适用），分别计算 SHA-256。不要只截图最终字符串。
4. “Magic”自动建议只能用于提出假设；必须把实际采纳的操作、参数和输入范围写入 recipe。

| 目标 | 可用操作示例 | 必须复核 |
| --- | --- | --- |
| 字符串编码线索 | From Hex、From Base64、URL Decode | HxD 原始字节、偏移、FLOSS/静态上下文 |
| 压缩/容器线索 | Gunzip、Inflate、Extract Files | 输入格式、派生物哈希；不执行提取物 |
| IOC 候选整理 | Extract URLs/IPs、Defang | 原始输出位置、PCAP/PML/内存上下文 |
| 字节比对 | SHA-256、To Hex、XOR | 独立 Get-FileHash/原始对象 |

### 2. 内存取证联动

从 Volatility/MemProcFS 导出的 VAD、文件对象或进程片段必须先记录镜像哈希、插件命令、PID、地址范围、权限与导出物哈希，再选取字节副本处理。将 CyberChef 结果回链到地址/偏移和进程；不能因文本“像命令”就断定进程运行过该命令。

### 3. recipe 留档

将 recipe 另存为案例文件，不使用含输入/recipe 的公共 URL 分享。复核者应在断网环境以同一输入哈希、版本和 recipe 重放；若版本不同，记录输出差异。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| 输出乱码/失败 | 保留输入编码、字节范围与错误；检查是否选错编码/压缩格式，不试图执行原对象 |
| 自动识别多种结果 | 记录候选，使用原始字节、格式头、静态/动态证据排除 |
| 大文件性能差 | 缩小到可追溯的最小字节范围；不丢弃原始导出物 |

- [ ] 已使用官方离线构建和断网浏览器，记录版本与哈希。
- [ ] 输入、recipe、参数、输出和每层派生物均可追溯且已哈希。
- [ ] 已保留原始字节、地址/偏移和独立工具复核。
- [ ] 未使用公共在线实例、外传 recipe URL、执行脚本或提取物。

## 官方资料

- [CyberChef 官方项目](https://github.com/gchq/CyberChef)
- [CyberChef Getting started](https://github.com/gchq/CyberChef/wiki/Getting-started)
