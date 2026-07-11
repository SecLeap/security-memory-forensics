# FakeDNS 安装实战手册

## 获取与安装

在隔离 Ubuntu 上创建独立虚拟环境，从 [fakedns PyPI 页面](https://pypi.org/project/fakedns/) 获取包；记录 Python 版本、包版本和安装日志。

```bash
python3 -m venv ~/fakedns-venv
~/fakedns-venv/bin/pip install fakedns
```

## 验证与最小使用

仅绑定实验网卡，为无害测试域名配置到 Ubuntu 实验地址的应答。用 Win11 的 `nslookup` 或 `Resolve-DnsName` 测试，保存查询日志、规则文件和规则哈希。

## 联动与回滚

FakeDNS 独占 53 端口；使用它时关闭/禁用 INetSim 的 DNS 服务。将查询时间、域名、类型、源 IP 与 PCAP、Windows PID 及内存网络对象对齐；实验后停止服务并还原 Ubuntu 快照。

## 使用方法

1. 在案例配置中定义无害测试域名到 Ubuntu 实验 IP 的应答，保存配置副本与 SHA-256。
2. 启动前用 `ss -lntup` 确认仅 FakeDNS 占用实验网卡的 53 端口。
3. 从 Win11 发起 `nslookup`/`Resolve-DnsName`，保存查询日志、PCAP 和响应结果。

## 实战场景与完成标准

场景：验证 Win11 测试程序的域名解析行为。完成标准是域名、查询类型、源 IP、时间与随后的 HTTP 会话可关联，且 DNS 服务未向外网递归转发。
