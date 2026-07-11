# 代码注入与异常内存

## 学习资料与练习

- [Volatility 3 Windows 插件参考](https://volatility3.readthedocs.io/en/latest/volatility3.plugins.windows.html)
- [YARA 文档](https://yara.readthedocs.io/)

在隔离实验机创建两个无害进程：一个只加载普通模块，另一个分配普通匿名内存。比较它们的地址空间、内存保护属性和线程入口，先建立正常基线；不要为练习编写或执行注入代码。

## 待办

- [ ] 匿名可执行内存、RWX 页面、异常 VAD/VMA 与映像缺失映射。
- [ ] DLL/so/dylib 注入、反射加载、进程空洞化、线程劫持与 shellcode。
- [ ] 线程起始地址、内存保护属性、导入信息和字节特征的交叉验证。
