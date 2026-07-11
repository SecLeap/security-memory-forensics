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

- [01-工具实践清单](01-工具实践清单.md)：按“安装—验证—分析—归档”执行的最小清单。

## 待办

- [ ] 内存采集工具与分析框架的兼容性、许可证、验证方法和风险记录。
- [ ] 采集脚本：参数校验、日志、哈希、重试、加密和副作用说明。
- [ ] 批量解析与结果标准化：JSON/CSV/Parquet、字段字典和错误处理。
- [ ] 内存取证实验室：虚拟机模板、快照、镜像样本和基准结果。
- [ ] 脚本静态检查、解析回归测试和文档链接检查。
