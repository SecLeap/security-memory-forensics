# 编程与脚本

## 学习目标

以“可复核的分析辅助”为边界：读取框架输出、规范化字段、计算哈希、提取命中上下文和生成报告。避免在未经审查的生产终端上运行采集或解析脚本。

## 推荐资料

- [Python `struct` 模块](https://docs.python.org/3/library/struct.html)：二进制结构与端序解析。
- [Python `hashlib` 模块](https://docs.python.org/3/library/hashlib.html)：镜像与输出的完整性校验。
- [Volatility 3 插件开发文档](https://volatility3.readthedocs.io/en/latest/writing-plugins.html)：理解插件输入、符号和对象模型。

## 最小实验

1. 编写脚本读取一个已保存的 JSON/CSV 插件输出，保留原始行号与来源文件。
2. 输出进程、PID、对象地址、插件名、分析时间五个统一字段。
3. 为输入镜像和生成报告分别写入 SHA-256，不修改原始镜像。

## 待办

- [ ] Python：二进制解析、正则、日志处理、API 调用和报告生成。
- [ ] PowerShell、Bash、zsh：安全采集、批量执行与结果归档。
- [ ] C/C++/Rust 基础：指针、结构体、ABI、内存布局和调试。
- [ ] SQL、JSON、YAML、CSV：证据标准化和查询。
- [ ] Git、虚拟环境、依赖锁定和可复现实验。
