# Linux 终端取证

## 学习主线

Linux 分析的难点通常不是插件命令，而是“镜像、运行内核、`vmlinux`、调试信息和符号表是否一致”。先理解 `task_struct`、`mm_struct`、VMA、文件描述符和 socket，再练习符号制作与验证。

## 推荐资料

- [Volatility 3 Linux 教程](https://volatility3.readthedocs.io/en/latest/getting-started-linux-tutorial.html)：覆盖采集、符号表、`linux.pslist`、`linux.pstree`、`linux.malfind` 等入门路径。
- [Volatility 3 Linux 符号表流程](https://volatility3.readthedocs.io/en/latest/symbol-tables.html)：使用 `dwarf2json` 制作与加载符号表。
- [Linux kdump 文档](https://docs.kernel.org/admin-guide/kdump/kdump.html)：理解 `vmcore` 的来源和 crash dump 机制；它不是任意时刻的 live RAM 镜像。
- [AVML](https://github.com/microsoft/avml)：Linux x86_64 用户态采集工具，输出可为 LiME 格式；内核 lockdown 会阻止采集。
- [LiME](https://github.com/jtsylve/LiME)：依赖与目标内核匹配的 LKM 采集方案。

## 实验顺序

1. 固定发行版、内核版本与架构，保存 `/boot` 中的内核及 debug 信息来源。
2. 使用公开 Linux 镜像完成 banner、进程树、bash 历史、socket 和可疑映射的基础练习。
3. 在实验机以 AVML 或匹配内核的 LiME 采集镜像，并立即计算哈希。
4. 用符号表运行相同插件；若失败，先验证内核版本/构建 ID，不要根据空输出下结论。

## 待办

- [ ] 内核任务结构、mm_struct、页表、slab、链表和 namespace。
- [ ] ELF、动态链接器、VMA、文件描述符、socket 与内核模块。
- [ ] /proc 与内存对象的映射关系及瞬态数据的验证方法。
- [ ] 容器、cgroup、eBPF 与最小化系统对内存解析的影响。
- [ ] 常见发行版、内核版本和内存镜像 profile/符号问题。
