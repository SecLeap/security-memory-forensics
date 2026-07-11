# Fiddler Classic 安装实战手册

## 获取与安装

从 [Fiddler Classic 官方安装文档](https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/installfiddler) 获取 Windows 安装程序，记录版本、哈希和许可证；安装在隔离 Win11 虚拟机。

## 验证与最小使用

1. 仅对无害的 Debian HTTP 测试服务配置代理，记录代理地址、端口和启用时间。
2. 导出会话时保留请求/响应时间与目标地址。
3. HTTPS 解密仅限自建测试服务和明确授权的流量；实验结束后移除临时根证书和代理设置。

## 内存取证联动

Fiddler 作为 HTTP 辅助视图，网络结论仍需 PCAP 或服务端日志复核，再关联内存中的 socket 与进程对象。

## 使用方法

1. 只对自建 Debian HTTP 服务开启捕获，记录代理监听端口和 Win11 代理设置变更。
2. 在 Sessions 中按进程/目标/时间筛选，导出请求和响应元数据；不把敏感正文写入报告。
3. 实验结束后关闭捕获、恢复代理设置，并移除临时解密证书（如曾在授权测试中使用）。

## 实战场景与完成标准

场景：辅助解释 HTTP 请求头和响应状态。完成标准是 Fiddler 会话与 PCAP、Apache 日志一致，并说明 Fiddler 无法覆盖非代理流量。
