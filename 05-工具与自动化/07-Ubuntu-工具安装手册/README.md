# Debian 工具安装手册

此目录按工具拆分 Debian 模拟服务端的部署。所有服务仅绑定内部实验网卡，不配置 NAT、桥接、默认出网路由或 DNS 转发。

- [01-FakeDNS](01-FakeDNS.md)
- [02-Apache HTTPD](02-Apache-HTTPD.md)
- [03-INetSim](03-INetSim.md)
- [04-tcpdump](04-tcpdump.md)

每次实验只能有一个 DNS:53 与一个 HTTP:80/443 监听者；FakeDNS/Apache 与 INetSim 默认服务可能冲突。

