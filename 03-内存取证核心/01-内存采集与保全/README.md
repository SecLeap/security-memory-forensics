# 内存采集与保全

## 采集前必答问题

1. 目标系统、版本、内核、架构、内存容量和安全配置是什么？
2. 需要的是全量物理内存、内核转储、进程转储，还是现有休眠/崩溃文件？
3. 采集工具是否与目标版本兼容，是否会加载驱动/模块或显著改变内存？
4. 输出空间、传输加密、哈希、命名规则和保管位置是否已经准备好？

## 三平台实验方案

| 平台 | 优先学习材料 | 实验产物 | 关键限制 |
| --- | --- | --- | --- |
| Windows | [完整内存转储](https://learn.microsoft.com/windows-hardware/drivers/debugger/complete-memory-dump)、[活动内核转储](https://learn.microsoft.com/windows-hardware/drivers/debugger/task-manager-live-dump)、[WinPmem](https://github.com/Velocidex/WinPmem) | `.dmp` 或采集工具原始镜像 | dump 覆盖范围不同；完整转储依赖启动卷页文件与足够空间 |
| Linux | [AVML](https://github.com/microsoft/avml)、[LiME](https://github.com/jtsylve/LiME)、[kdump](https://docs.kernel.org/admin-guide/kdump/kdump.html) | LiME/AVML 镜像或 `vmcore` | AVML 面向 x86_64；kernel lockdown、内核模块匹配和权限会影响可采集性 |
| macOS | [Volatility macOS 教程](https://volatility3.readthedocs.io/en/latest/getting-started-mac-tutorial.html)、[osxpmem](https://github.com/google/rekall/tree/master/tools/osxpmem) | 经兼容性验证的镜像 | 现代系统、SIP 与 Apple Silicon 限制显著；先用公开镜像练习 |

## Linux AVML 最小实验

仅在隔离、授权的 x86_64 Linux 实验机上执行，并先从项目 release 获取后校验二进制：

```bash
sudo avml acquire output.lime
sha256sum output.lime > output.lime.sha256
```

AVML 官方支持压缩 LiME 输出、格式转换和上传；本仓库只将本地采集与哈希作为起步练习。不要把含有敏感内存数据的镜像上传到不受控位置。

## 采集记录模板

```text
镜像编号：
目标系统/内核/架构：
采集工具与版本（含二进制哈希）：
开始/结束时间与时区：
输出格式、大小与 SHA-256：
采集副作用、报错与异常：
符号/调试信息来源：
```

## 待办

- [ ] Live RAM、虚拟机快照、休眠文件、页面文件、崩溃转储的适用边界。
- [ ] Windows、Linux、macOS 常用采集方案、权限、兼容性和副作用。
- [ ] 本地与远程采集、带宽控制、加密传输、分片、校验和链路记录。
- [ ] 采集失败、系统不稳定、磁盘不足与敏感数据暴露的应对策略。
