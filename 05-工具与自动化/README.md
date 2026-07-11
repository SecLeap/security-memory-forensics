# 工具与自动化

## 工具选择原则

先验证“是否支持目标镜像和系统版本”，再讨论功能。所有工具都应记录获取渠道、版本、二进制 SHA-256、许可证、目标平台、运行权限、输出格式和已知限制。优先在分析工作站使用副本，不让分析工具接触唯一原始镜像。

## 工具地图

| 类别 | 工具/资料 | 首要用途 | 注意事项 |
| --- | --- | --- | --- |
| 框架 | [Volatility 3](https://github.com/volatilityfoundation/volatility3) | 跨平台离线内存解析 | Linux/macOS 的符号与兼容性需先验证 |
| Windows 采集 | [WinPmem](https://github.com/Velocidex/WinPmem)、[Windows dump 文档](https://learn.microsoft.com/windows-hardware/drivers/debugger/complete-memory-dump) | 实验镜像或 dump 获取 | 驱动加载、系统版本和 dump 覆盖范围必须记录 |
| Linux 采集 | [AVML](https://github.com/microsoft/avml)、[LiME](https://github.com/jtsylve/LiME) | Linux 内存镜像 | AVML 架构、lockdown 与 LiME 内核模块匹配是前置条件 |
| macOS 采集/解析 | [Volatility macOS 教程](https://volatility3.readthedocs.io/en/latest/getting-started-mac-tutorial.html)、[osxpmem](https://github.com/google/rekall/tree/master/tools/osxpmem) | 兼容的历史/实验环境 | 现代 macOS 的可采集性与插件维护有限，先做兼容性验证 |
| 调试/验证 | [WinDbg](https://learn.microsoft.com/windows-hardware/drivers/debugger/)、[GDB](https://www.sourceware.org/gdb/documentation/) | dump、符号和结构交叉验证 | 不替代内存取证框架的结论链 |
| 特征扫描 | [YARA](https://yara.readthedocs.io/) | 已授权镜像的字节模式定位 | 命中只是线索，必须分析命中地址的上下文 |

## 工具实践入口

| 层级 | 入口 | 使用方式 |
| --- | --- | --- |
| 通用规范 | [01-工具实践清单](01-工具实践清单.md) | 先阅读：安装、验证、分析、归档的共同要求 |
| 核心框架 | [02-Volatility3-实战手册](02-Volatility3-实战手册.md) | 单独完成三端镜像的符号、插件与输出练习 |
| 平台总览 | [03-Windows11-分析工具实战手册](03-Windows11-分析工具实战手册.md) / [04-Debian-模拟服务工具实战手册](04-Debian-模拟服务工具实战手册.md) | 了解工具组合和证据边界，不重复单工具安装步骤 |
| 环境联动 | [05-恶意软件内存分析环境实战手册](05-恶意软件内存分析环境实战手册.md) | 将 Win11 与 Debian 工具串成可复现实验 |
| 单工具实战 | [06-Windows11-工具安装手册](06-Windows11-工具安装手册/README.md) / [07-Debian-工具安装手册](07-Debian-工具安装手册/README.md) | 按工具逐份完成安装、验证、使用和场景练习 |

工具安装与使用细节只在 `06`、`07` 两个逐工具目录维护；其他手册仅链接到它们。

## 工具学习顺序

1. 先完成 Volatility 3 公开镜像分析，理解镜像、符号、插件和输出归档。
2. 再在 Win11 实验机使用静态与动态观察工具，建立进程/网络的正常基线。
3. 最后配置 Debian 受控服务，以服务端日志、PCAP 和内存对象验证同一行为。

## 待办

- [ ] 内存采集工具与分析框架的兼容性、许可证、验证方法和风险记录。
- [ ] 采集脚本：参数校验、日志、哈希、重试、加密和副作用说明。
- [ ] 批量解析与结果标准化：JSON/CSV/Parquet、字段字典和错误处理。
- [ ] 内存取证实验室：虚拟机模板、快照、镜像样本和基准结果。
- [ ] 脚本静态检查、解析回归测试和文档链接检查。
