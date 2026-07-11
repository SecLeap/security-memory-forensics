# 对象与痕迹分析

## 推荐的对象分析顺序

1. 镜像身份、系统信息、内核/符号匹配。
2. 进程清单与进程树；再对异常 PID 做线程、令牌、句柄和命令行检查。
3. 虚拟内存区域、加载模块、映射文件与可执行匿名页。
4. socket、连接与网络配置对象，并关联回所属进程。
5. 字符串、环境变量、用户态 heap 与其他对象字段；只作为线索，回到结构或地址验证。

## 恶意软件内存分析：安全学习边界

本仓库仅记录“从已有镜像中识别异常内存”的方法，不提供恶意代码编写、投递或规避操作。学习重点是进程注入、反射加载、异常内存保护属性、可疑线程起始地址、Hook 和无文件代码的取证可见性。使用公开教学镜像或自建隔离样本，禁止把样本或含敏感数据的镜像提交到仓库。

## 推荐资料

- [Volatility 3 Windows 插件参考](https://volatility3.readthedocs.io/en/latest/volatility3.plugins.windows.html)
- [Volatility 3 Linux 插件参考](https://volatility3.readthedocs.io/en/latest/volatility3.plugins.linux.html)
- [YARA 文档](https://yara.readthedocs.io/)：用于对已授权镜像中的字节模式做扫描；规则命中需结合上下文验证。

## 待办

- [ ] 进程/线程：隐藏进程、父子关系、命令行、令牌与异常线程。
- [ ] 内存映射：VAD/VMA、可执行匿名页、注入、Hook、模块与 DLL/so/dylib。
- [ ] 网络：socket、连接、监听端口、DNS 缓存与代理配置。
- [ ] 文件与注册表：打开文件、缓存、注册表 hive 与剪贴板的内存表示。
- [ ] 字符串、环境变量、命令行、用户态 heap 与已释放对象的分析边界。
