# Debian 模拟服务机

## 建设目标

Debian 虚拟机只向隔离 Windows 虚拟机提供可观测、可复位的 DNS、HTTP 与其他模拟网络服务，并保存访问日志。它不是跳板机、代理或互联网出口。

## 组件与职责

| 组件 | 职责 | 保留证据 | 注意事项 |
| --- | --- | --- | --- |
| FakeDNS | 将实验域名解析到 Debian 模拟地址 | DNS 查询名、类型、时间、客户端 IP | 仅绑定实验网卡；与 INetSim DNS 互斥 |
| Apache HTTPD / `apache2` | 返回固定、无害的 HTTP 响应 | access/error log、响应内容版本 | 与 INetSim HTTP 互斥；不放置真实可执行文件 |
| INetSim | 模拟多种互联网服务并记录请求 | session/report/service log | 不作为真实服务代理；按场景启用单独服务 |
| tcpdump / Wireshark | 在 Debian 侧捕获实验网卡流量 | PCAP 与抓取过滤条件 | 仅抓实验接口，避免采集无关流量 |

## 部署顺序

1. 安装最小化 Debian，接入实验内部网络，设置静态地址并禁用默认路由与 DNS 转发。
2. 安装并阅读 INetSim：官方文档要求以低权限用户运行服务，配置参数以 `inetsim.conf` 和 man page 为准；参见 [INetSim 文档](https://www.inetsim.org/documentation.html) 与 [Debian man page](https://manpages.debian.org/inetsim/inetsim.1.en.html)。
3. 安装 Apache，只提供固定、无害的测试页面；为每次实验的页面内容赋予版本号与 SHA-256。
4. 在 Python 虚拟环境中安装并验证 [fakedns](https://pypi.org/project/fakedns/)；配置规则前先阅读其项目说明，并用 `dig`/`nslookup` 从 Windows 测试机确认解析仅指向 Debian。
5. 为 DNS、HTTP、INetSim 和 PCAP 分别设置时间同步、日志目录、轮转和案例编号；不覆盖历史日志。
6. 用无害测试程序验证“DNS 请求 → HTTP 请求 → 服务端日志 → Windows PCAP”这条链路，之后再制作 Debian 的干净快照。

## 服务启停核对

每次实验前记录：当前模式、监听地址/端口、服务版本、FakeDNS 规则文件哈希、Apache 页面哈希、INetSim 配置哈希和抓包文件名。先确认 53、80、443 等端口没有重复监听，再启动 Windows 分析机。

## Debian 侧最小证据包

```text
案例编号/
  dns/          # FakeDNS 查询日志与规则副本
  http/         # Apache access/error log、响应内容哈希
  inetsim/      # session、report、服务日志与配置副本
  pcap/         # 实验网卡抓包与过滤条件
  环境元数据/   # IP、端口、版本、时间、服务启停记录
```

