# WinPmem 安装实战手册

## 获取与安装

从 [Velocidex WinPmem 官方项目](https://github.com/Velocidex/WinPmem) 获取 release 和哈希。该项目页面说明其公开支持范围主要到 Windows 10；在 Windows 11 上必须先用干净快照验证驱动加载、采集完整性和 Volatility 可解析性。

## 验证与最小使用

仅在授权的隔离实验机、管理员权限和足够输出空间条件下运行。项目示例的独立采集器命令为：

```powershell
winpmem_mini_x64.exe C:\Lab\Evidence\physmem.raw
```

立即计算 SHA-256，记录工具/驱动版本、命令、开始/结束时间、输出大小和报错。不要为了加载未签名驱动而更改测试签名或其他系统安全设置。

## 内存取证联动

先运行 `windows.info` 验证镜像，再做进程、VAD、模块与网络分析。WinPmem 产生 RAW 镜像；不要将其与 Windows 内核转储或进程 dump 混为同一种证据。

## 使用方法

1. 在干净 Win11 快照验证工具/驱动兼容性并预留至少与 RAM 相当的输出空间。
2. 采集前记录 PID、网络状态、工具哈希和时间；采集后立刻计算镜像 SHA-256。
3. 将原始 RAW 只读保存，用副本运行 Volatility 3；记录 `windows.info` 成功或失败的完整输出。

## 实战场景与完成标准

场景：在无害 DNS→HTTP 实验的连接期间采集一次镜像。完成标准是镜像、采集日志、Wireshark、Debian 日志和 Volatility 网络/进程输出有统一案例编号和时间线。
