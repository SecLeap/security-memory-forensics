# Apache HTTPD 实战手册

> 适用范围：在隔离 Ubuntu 模拟服务机中提供固定、无害的 HTTP 响应，并保留服务端访问证据。Apache 仅用于内部实验网络；不承载真实业务、样本、凭据或互联网代理服务。

Ubuntu 的软件包名通常为 `apache2`。本手册用一个案例一个站点目录的方式保存页面、配置和日志；若本次由 INetSim 模拟 HTTP，则停止 Apache 或避免其监听冲突端口。

## 获取与准备

1. 在隔离 Ubuntu 中从发行版可信软件源准备 `apache2`，记录发行版版本、软件包版本、仓库来源和虚拟机快照。
2. 为案例创建独立的站点内容、虚拟主机配置与日志目录。页面只能是固定文本或其他无害内容，并计算 SHA-256。
3. 启动前确认实验网卡上的 TCP 80/443 没有被 INetSim 或其他服务占用。

```bash
sudo apt update
sudo apt install apache2
apache2ctl -v
apache2ctl configtest
ss -lntup
```

## 证据准备

```text
<案例编号>/ubuntu/apache/
├─ site/                # 固定无害页面及 SHA-256
├─ config/              # 虚拟主机配置副本
├─ logs/                # access.log、error.log
├─ commands.txt         # 启停时间、绑定地址、版本和检查结果
└─ manifest.sha256      # 页面、配置和日志哈希清单
```

记录站点配置、页面版本、监听地址、端口、服务启停 UTC 以及 access/error log 的原始副本。不要使用生产证书、真实域名、真实用户数据或可执行下载内容。

## 使用方法

### 1. 建立案例站点

1. 复制一份案例虚拟主机配置，DocumentRoot 指向案例的固定无害页面；不要直接复用生产站点配置。
2. 为 access/error 日志指定案例专用位置，先执行 `apache2ctl configtest`，再按本机服务管理方式启用该配置。
3. 使用 `ss -lntup` 和服务状态输出记录 Apache 的监听地址；只允许实验网卡访问所需端口。

### 2. 验证请求与日志

1. 从 Win11 分析机请求固定测试页面，记录请求时间、URL 路径和客户端 IP；不要提交或下载样本。
2. 在 Ubuntu 保存 access/error log，并在实验接口抓取对应 HTTP 会话。
3. 将响应页面 SHA-256、HTTP 状态码、Host、路径、User-Agent、源 IP 与时间写入实验记录。

## 与内存取证联动

以时间和五元组将 Apache access log、Ubuntu PCAP、Win11 Wireshark/Procmon 与镜像网络对象关联。HTTP 日志反映的是服务端请求视图，不足以确定 Windows 端进程；应使用 PID、进程创建时间和独立网络证据复核。详细镜像分析流程见[内存取证标准分析工作流](../../03-内存取证核心/05-标准分析工作流/README.md)。

## 常见问题与检查清单

| 现象 | 处理方式 |
| --- | --- |
| `configtest` 失败 | 保存错误输出，修正案例配置；不要用强制启动绕过配置错误。 |
| 80/443 端口已被占用 | 检查 INetSim 和现有 Apache 实例，保留端口清单后停止或改绑冲突服务。 |
| access log 没有请求 | 核对实验网卡、Win11 DNS 解析、站点绑定地址和防火墙规则。 |

- [ ] 已记录软件包版本、站点/页面哈希、配置测试结果和快照编号。
- [ ] 页面固定无害，服务只监听实验网卡，未启用外网代理或真实业务内容。
- [ ] access/error log 与 Ubuntu PCAP 已保存并按时间、五元组关联。
- [ ] 实验结束后已停止服务并还原快照。

## 官方资料

- [Apache HTTP Server 文档](https://httpd.apache.org/docs/)
- [Ubuntu Apache2 文档](https://documentation.ubuntu.com/server/how-to/web-services/apache2/)
