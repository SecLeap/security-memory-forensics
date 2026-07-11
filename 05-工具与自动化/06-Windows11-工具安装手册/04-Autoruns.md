# Autoruns / Autorunsc 实战手册

> 适用范围：隔离 Win11 实验机中，记录启动配置在实验前后的差异。Autoruns 发现的是配置的自动启动位置，不等于对应程序已运行、已成功持久化或在内存快照中仍存在。

[Autoruns](https://learn.microsoft.com/sysinternals/downloads/autoruns) 覆盖 Logon、Services、Scheduled Tasks、Explorer、AppInit、Winlogon 等多类自动启动位置，并包含可导出 CSV 的命令行版 Autorunsc。本手册仅用于查看和导出，禁止取消勾选、删除、跳转执行或启用 VirusTotal 上传/查询。

## 获取与安装

从官方 Sysinternals 页面获取包，解压至 C:\Lab\Tools\Sysinternals\Autoruns\，记录发布包、Autoruns/Autorunsc 主程序版本、签名与 SHA-256。用 VM 快照上的无害测试键值验证前后导出；不通过修改真实系统启动项验证工具。

## 前后基线

    C:\Lab\Cases\LAB-001\01-启动项\
    ├─ LAB-001-before.arn
    ├─ LAB-001-before.csv
    ├─ LAB-001-after.arn
    ├─ LAB-001-after.csv
    └─ LAB-001-差异复核.md

1. 测试前记录 UTC、用户、权限、OS 版本和 Autoruns 过滤选项，导出完整基线。
2. 测试后停止 Procmon、完成第二份导出。两次采用相同用户、权限和筛选范围。
3. 保存原始导出、输入哈希和导出文件哈希；若使用 Autorunsc，保留完整命令、版本和退出状态。

## 使用方法

### 1. GUI 差异审阅

1. 先看 All，再按 Logon、Services、Scheduled Tasks、Drivers 等类别缩小；记录条目的 Location、Entry、Image Path、Publisher、签名提示、用户和时间。
2. Hide Signed Microsoft Entries 仅是减少噪声的显示过滤，不可使隐藏条目从证据中消失；保存该选项状态。
3. 对前后差异建立表格，并以 Procmon 的 RegSetValue/CreateFile/服务创建事件和 Regshot 差异复核。

### 2. 命令行留档

Autorunsc 的选项随版本变化，以本机帮助和官方页为准。建议先保存全量 CSV，再在副本中筛选；禁止使用会查询或提交外部服务的参数。

    Set-Location 'C:\Lab\Tools\Sysinternals\Autoruns'
    .\Autorunsc.exe -a * -c > 'C:\Lab\Cases\LAB-001\01-启动项\LAB-001-after.csv'

该命令只是例子；执行前记录当前版本帮助、实际选项、用户和时间。输出路径与标准输出重定向必须同案例证据链一起留档。

## 与内存取证联动

对每个差异：记录启动位置、映像路径/命令行、PID 线索和时间；在内存镜像中检查对应进程、服务、模块、命令行和 VAD。快照未出现不否定配置存在，反之亦然。仅在三者时间和对象关系可解释时，报告“配置差异与进程对象相关”。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| 差异极多 | 核对用户、权限、OS 更新和显示过滤；保留完整导出再筛选 |
| 条目路径缺失/签名未知 | 保留原始字段，哈希工作副本并用 PE 工具检查；不执行目标 |
| 想禁用/删除条目 | 停止；本手册仅记录，清理/修复需独立授权 |

- [ ] 已保存前后原始导出、筛选状态、输入/输出 SHA-256。
- [ ] 每项关键差异均有 Procmon/Regshot 和必要内存对象复核。
- [ ] 未使用禁用、删除、VirusTotal 或在线查询功能。

## 官方资料

- [Autoruns / Autorunsc 官方说明](https://learn.microsoft.com/sysinternals/downloads/autoruns)
