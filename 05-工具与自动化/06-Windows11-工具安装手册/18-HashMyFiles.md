# HashMyFiles 安装实战手册

## 获取与安装

从 [NirSoft HashMyFiles](https://www.nirsoft.net/utils/hash_my_files.html) 获取便携包，核对哈希并解压至 `C:\Lab\Tools\HashMyFiles`。也可使用 Windows 内置 `Get-FileHash` 做独立复核。

## 验证与最小使用

对工具安装包、样本副本、镜像、PCAP、PML 和报告计算 SHA-256。导出清单时包含完整路径、大小、算法、值、工具版本和计算时间。

## 内存取证联动

哈希保证文件级一致性，不能证明镜像中的内存页与磁盘文件相同；内存内容仍需按地址和上下文分析。

## 使用方法

1. 拖入安装包、样本副本、镜像和日志副本，统一选择 SHA-256。
2. 导出清单后再用 `Get-FileHash` 抽样复核，记录两者计算时间和路径。
3. 原始镜像哈希与分析副本哈希分别保存，避免混淆。

## 实战场景与完成标准

场景：为一次 WinPmem 采集建立完整性链。完成标准是工具、镜像、PML、PCAP、服务日志和报告均有独立 SHA-256 清单。
