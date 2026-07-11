# Ubuntu 模拟服务工具实战手册

Ubuntu 在实验室中充当受控服务与证据记录端：接收 Win11 实验机的 DNS/HTTP 等请求并写入日志。它绝不能作为互联网出口、代理、跳板或生产服务。

单个服务的安装、验证、使用方法与场景以 [Ubuntu 逐工具手册](07-Ubuntu-工具安装手册/README.md) 为准；本页只保留服务组合、端口关系和证据归档。

## 工具总表

| 工具 | 职责 | 实践产物 | 端口关系 |
| --- | --- | --- | --- |
| FakeDNS | 将实验域名解析到 Ubuntu 地址 | 查询日志、规则副本、规则哈希 | 独占 DNS 53；与 INetSim DNS 冲突 |
| Apache HTTPD / `apache2` | 提供固定无害 HTTP 响应 | access/error log、页面副本哈希 | 独占 HTTP 80/443；与 INetSim HTTP 冲突 |
| INetSim | 模拟多种互联网服务 | session/report/service log、配置副本 | 默认可能占用 DNS/HTTP 等端口 |
| tcpdump / Wireshark | Ubuntu 侧实验网卡抓包 | PCAP、抓包条件与接口名 | 不监听宿主/办公网络接口 |
| `ss` / `lsof` / `journalctl` | 监听与服务状态核验 | 端口监听清单、服务日志 | 实验开始前检查端口唯一性 |

## 安装与基线

在断网或严格受控的 Ubuntu 实验机上，从发行版可信仓库或项目官方 release 获取工具；安装完成后记录软件包版本与配置哈希。推荐将服务运行在非特权账户，日志写入案例专用目录。

```bash
# 仅作为实验机准备示例；先核验仓库来源与网络隔离
sudo apt update
sudo apt install apache2 inetsim tcpdump
python3 -m venv ~/fakedns-venv
~/fakedns-venv/bin/pip install fakedns
```

以上命令不应在生产服务器或可出网的日常主机执行。FakeDNS 具体参数以其 [PyPI 项目说明](https://pypi.org/project/fakedns/) 为准；INetSim 配置以[官方文档](https://www.inetsim.org/documentation.html)和本地 `inetsim.conf` 注释为准。

## 三种服务模式

| 模式 | 启动服务 | 用途 | 启动前核验 |
| --- | --- | --- | --- |
| DNS/HTTP 分离 | FakeDNS + Apache | 固定 DNS 解析和可控 HTTP 内容 | FakeDNS 唯一占用 53；Apache 唯一占用 80/443 |
| 全服务模拟 | INetSim | 快速记录多协议服务尝试 | FakeDNS、Apache 已停止；确认 INetSim 监听范围 |
| 混合模拟 | FakeDNS + Apache + INetSim 的非冲突服务 | 需要自定义 DNS/HTTP，同时记录其他协议 | 在 `inetsim.conf` 关闭/改绑冲突服务，核验端口唯一性 |

## FakeDNS 实战

1. 仅绑定 Ubuntu 的实验网卡地址；不要监听所有生产网卡。
2. 为每次实验保存规则文件副本和 SHA-256，将测试域名解析到 Ubuntu 实验地址。
3. 从 Win11 使用无害 `nslookup` 或 `Resolve-DnsName` 验证解析；记录查询时间、类型、客户端 IP 和响应地址。
4. 将 DNS 日志与 Wireshark 的 DNS 包、Win11 进程 PID、Volatility 网络对象交叉对齐。

## Apache 实战

1. 每个案例使用独立站点目录，只放置固定、无害的测试页面；页面文件计算 SHA-256。
2. 启动前确认 Apache 是 80/443 的唯一监听者；需要 TLS 时使用自签名测试证书并记录指纹。
3. 保留 access/error log、站点配置、页面副本和服务启停时间。
4. 以请求路径、Host、User-Agent、时间与源 IP 关联 PCAP；不要根据单一 HTTP 日志推断 Win11 中的进程归属。

## INetSim 实战

1. 从样例配置复制出案例配置，不直接修改唯一的全局配置；对配置文件计算 SHA-256。
2. 选择需要模拟的服务，关闭 DNS/HTTP 等冲突服务或让它们不绑定实验端口。
3. 使用独立 `log`、`report`、`data` 目录保存 session 与服务日志；记录启动命令、绑定地址和时间。
4. 实验后将 INetSim report 与 Win11 PCAP/Procmon 逐项比对，区分“服务端收到请求”与“内存中仍可看到连接”。

## 最小证据归档

```text
<案例编号>/ubuntu/
  fakedns/规则副本、查询日志、哈希
  apache/站点副本、access/error log、配置哈希
  inetsim/配置副本、session、report、服务日志
  pcap/抓包、接口、过滤条件
  环境/软件包版本、监听端口清单、IP、服务启停记录
```
