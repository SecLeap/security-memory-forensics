# Noriben 安装实战手册

## 获取与安装

从 [Noriben 官方项目](https://github.com/Rurik/Noriben) 获取源码，置于 `C:\Lab\Tools\Noriben`；使用独立 Python 环境，并把经验证的 `Procmon.exe` 路径写入 Noriben 配置。记录 Git commit、Python 版本与 Procmon 版本。

## 验证与最小使用

1. 用无害测试程序先运行一次，确认 Noriben 能启动/停止 Procmon 并生成报告。
2. 保留 Noriben 配置、标准输出、报告、CSV 和原始 PML。
3. 人工复核过滤规则和摘要行，避免将被排除的事件误认为未发生。

## 内存取证联动

Noriben 仅帮助整理 Procmon 时间线。以报告中的 PID、时间和路径为线索回查 Volatility 与原始 PML。

## 使用方法

1. 在独立 Python 环境执行 `python Noriben.py --help`，先确认当前参数和配置文件位置。
2. 用无害测试程序跑一次完整采集，核验 Noriben 生成的 PML、文本报告和 CSV 是否属于同一案例。
3. 从摘要中挑选进程创建、文件写入、注册表与网络相关事件，逐条回查原始 PML。

## 实战场景与完成标准

场景：将高噪声 Procmon 记录压缩为可读的行为时间线。完成标准是报告中的每一个摘要事件都能回溯到 PML 行/事件，而不是只引用 Noriben 的结论。
