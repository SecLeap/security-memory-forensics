# INetSim 安装实战手册

## 获取与安装

在隔离 Debian 从可信仓库安装：

```bash
sudo apt update
sudo apt install inetsim
```

INetSim 官方要求以低权限用户运行服务；配置项以 [INetSim 文档](https://www.inetsim.org/documentation.html)、本地 `inetsim.conf` 注释和 man page 为准。复制案例配置，不直接改写唯一全局配置；记录配置 SHA-256。

## 验证与最小使用

选择“全服务模拟”时，停止 FakeDNS 和 Apache，确认 INetSim 的监听地址、端口和日志目录。先用无害客户端验证 session/report/service log 是否生成。

## 联动与回滚

混合模式中必须关闭/改绑 INetSim 的 DNS/HTTP 冲突服务。将 session/report 与 PCAP、Win11 PID、Volatility 网络对象按时间和五元组对齐；实验结束后停止服务并还原快照。

## 使用方法

1. 从模板复制出案例 `inetsim.conf`，配置日志、report、data 和实验网卡绑定；记录配置哈希。
2. 在启动前选择要模拟的服务并关闭冲突服务，检查监听端口。
3. 使用无害客户端测试后，保存 session、report、服务日志和 Debian PCAP。

## 实战场景与完成标准

场景：观察测试程序尝试访问哪些模拟协议。完成标准是每个服务端记录都能对应 PCAP 会话，并说明连接关闭后镜像可能不再可见。
