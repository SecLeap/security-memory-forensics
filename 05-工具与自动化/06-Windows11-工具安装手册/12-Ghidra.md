# Ghidra 安装实战手册

## 获取与安装

从 [Ghidra 官方 release](https://github.com/NationalSecurityAgency/ghidra/releases) 获取发布包。安装前核对 Java 运行时要求，解压至 `C:\Lab\Tools\Ghidra`；记录 release、JDK 版本、哈希和许可证。

## 验证与最小使用

为样本副本创建独立项目，导入后记录入口点、函数、字符串和导入；将项目导出/注释与样本哈希一起归档。

## 内存取证联动

Ghidra 的函数地址需结合运行时模块基址换算，才能与 x64dbg/WinDbg 和 Volatility 的内存地址比较。

## 使用方法

1. 新建以案例编号命名的项目，导入样本副本并记录导入选项。
2. 标注入口点、关键字符串、函数和调用关系，导出注释/项目归档。
3. 使用相对虚拟地址（RVA）记录函数位置，并在报告中写明换算规则。

## 实战场景与完成标准

场景：将静态函数标注与 x64dbg/Volatility 的运行时地址关联。完成标准是地址计算可复现，且样本/模块哈希明确。
