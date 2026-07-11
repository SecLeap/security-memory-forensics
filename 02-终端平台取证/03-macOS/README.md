# macOS 终端取证

## 学习主线与现实边界

macOS 以 XNU/Mach、`task`/`thread`、`vm_map`、Mach port 与 dyld 为主线。现代 macOS 的现场内存采集受 SIP、硬件和系统安全模型强约束；将“可采集性”作为待验证前提，不能把旧工具的成功经验直接套用于 Apple Silicon 或新系统版本。

## 推荐资料

- [Volatility 3 macOS 教程](https://volatility3.readthedocs.io/en/latest/getting-started-mac-tutorial.html)：含 `mac.pslist`、`mac.pstree`、网络与符号表步骤。
- [Volatility 3 macOS 符号表说明](https://volatility3.readthedocs.io/en/latest/symbol-tables.html)：学习 ISF 与 `dwarf2json` 的生成流程。
- [Apple XNU 源码](https://github.com/apple-oss-distributions/xnu)：以目标系统版本为准阅读 VM 与 task 结构。
- [osxpmem](https://github.com/google/rekall/tree/master/tools/osxpmem)：历史采集参考。Volatility 官方明确提示 macOS 插件维护有限，实验前必须核对工具、macOS 版本、Intel/Apple Silicon 和安全配置的兼容性。

## 实验顺序

1. 先使用公开 macOS 镜像，完成进程树、接口与 bash 历史等基础插件练习。
2. 记录目标 macOS 版本、硬件架构、内核版本、SIP 状态和符号来源。
3. 仅在授权实验机验证采集方案；采集失败须记录原因，不应关闭安全机制来“强行成功”。

## 待办

- [ ] XNU、Mach task/thread、vm_map、IPC port、zone 和内核扩展。
- [ ] Mach-O、dyld、进程地址空间、共享缓存和代码签名的内存表示。
- [ ] 虚拟内存、压缩内存、交换文件与休眠映像的取证意义。
- [ ] Intel 与 Apple Silicon、SIP、FileVault 及系统版本对内存采集/解析的影响。
