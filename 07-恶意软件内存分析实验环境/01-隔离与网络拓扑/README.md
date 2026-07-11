# 隔离与网络拓扑

## 推荐拓扑

```text
                    ┌──────────────────────────┐
                    │ 仅主机/内部虚拟网络       │
                    │ 无 NAT、无桥接、无默认路由 │
                    └────────────┬─────────────┘
                                 │
              192.168.56.20     │     192.168.56.10
       ┌─────────────────────┐   │   ┌─────────────────────┐
       │ Windows 11 分析机   │───┴──▶│ Debian 模拟服务机     │
       │ DNS 指向 Debian     │       │ FakeDNS / Apache /   │
       │ Wireshark + 采集工具│       │ INetSim（按场景启用） │
       └─────────────────────┘       └─────────────────────┘
```

IP 地址仅为实验示例，可替换为与实际网络不重叠的私有地址段。重点是 Windows 只能访问 Debian 模拟服务，不能访问互联网、办公网或宿主机服务。

## 建设清单

1. 在虚拟化平台创建一个仅主机（Host-only）或内部（Internal）交换网络；不要接 NAT 或桥接适配器。
2. 为 Debian 与 Windows 设置静态地址；Windows DNS 仅指向 Debian，默认网关留空或指向不可路由地址。
3. 禁用虚拟机与宿主机之间的共享目录、剪贴板、拖放、USB 直通和自动挂载。
4. 在 Debian 本机防火墙上仅允许实验所需端口；在宿主机防火墙上拒绝该实验网段的转发/出网。
5. 分别创建 `debian-clean`、`win11-clean` 快照；记录虚拟化产品版本、网卡 MAC、IP 和快照时间。

## 端口冲突规则

FakeDNS、Apache HTTPD（Debian 软件包通常名为 `apache2`）和 INetSim 默认都可能占用常见服务端口。**不要将三者按默认配置同时启动。**每次实验先选择一个模式：

| 模式 | DNS:53 | HTTP:80/443 | 适用问题 |
| --- | --- | --- | --- |
| DNS/HTTP 分离 | FakeDNS | Apache | 观察 DNS 请求后访问固定 HTTP 响应的行为 |
| 全服务模拟 | INetSim | INetSim | 快速观察样本尝试哪些协议与路径 |
| 混合模拟 | FakeDNS | Apache；INetSim 仅启用未冲突服务 | 需要固定 DNS/HTTP 内容，同时记录其他协议尝试 |

FakeNet-NG 属于 Win11 本地网络模拟模式，应与上表的 Debian 服务模式二选一。其详细使用见 [FakeNet-NG 实战手册](../../05-工具与自动化/06-Windows11-工具安装手册/29-FakeNet-NG.md)。

使用混合模式时，依据 [INetSim 配置文档](https://www.inetsim.org/documentation.html) 在 `inetsim.conf` 中禁用或改绑与 FakeDNS/Apache 冲突的服务；先用端口检查工具确认唯一监听者。

## 实验结束动作

1. 停止 Windows 上的测试进程和 Debian 模拟服务。
2. 导出内存镜像、PCAP、Procmon PML/CSV、DNS/HTTP/INetSim 日志并计算 SHA-256。
3. 将证据复制到分析工作站的只读案例目录；不得直接把受污染虚拟磁盘作为日常工作盘。
4. 关闭虚拟机并还原到干净快照。
