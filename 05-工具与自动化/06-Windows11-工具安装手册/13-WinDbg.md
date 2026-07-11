# WinDbg 安装实战手册

## 获取与安装

优先使用 [Microsoft WinDbg 安装文档](https://learn.microsoft.com/windows-hardware/drivers/debugger/)。在受控 Win11 上可使用：

```powershell
winget install Microsoft.WinDbg
```

记录安装来源、版本和符号缓存目录；不要使用来路不明的调试器副本。

## 验证与最小使用

先打开公开或无害测试 dump，验证符号加载和基本信息。记录 dump SHA-256、WinDbg 版本、符号路径、命令与完整输出。调试实时内核或生产进程不属于本实验室的默认动作。

## 内存取证联动

WinDbg 用于验证 Windows 转储结构、符号和地址；Volatility 3 用于取证对象分析。两种结果不一致时保留两边输出，先审查 dump 范围和符号。

## 使用方法

1. 打开无害测试 dump，设置并记录符号路径；确认符号加载结果后再查询对象。
2. 保存 WinDbg 版本、命令历史、控制台输出和 dump SHA-256。
3. 对地址或模块信息使用只读查询；不对实时内核/生产进程执行调试控制动作。

## 实战场景与完成标准

场景：验证 Windows dump 的内核/符号信息，再与 `windows.info` 结果对照。完成标准是明确 dump 覆盖范围和符号状态，不把调试失败等同于取证发现。
