# 内核模块与驱动异常

## 学习资料与练习

- [Windows 驱动调试概述](https://learn.microsoft.com/windows-hardware/drivers/debugger/)
- [Linux 内核模块文档](https://docs.kernel.org/kbuild/modules.html)

练习应从系统自带、已签名或自建无害模块的加载状态开始，对比模块列表、内存映射和对象扫描。不要在实验以外加载第三方内核模块或驱动。

## 待办

- [ ] 已加载列表、对象扫描和内存映射的交叉核验。
- [ ] Windows 驱动、Linux 内核模块、macOS 内核组件的结构差异。
- [ ] Hook、回调、系统调用表和隐藏内核对象的内存侧验证。
