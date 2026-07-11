# 可疑进程与隐藏对象

## 学习资料与练习

- [Volatility 3 Windows 教程](https://volatility3.readthedocs.io/en/latest/getting-started-windows-tutorial.html)
- [Volatility 3 Linux 教程](https://volatility3.readthedocs.io/en/latest/getting-started-linux-tutorial.html)

先比较进程链表枚举、进程扫描和进程树。将“扫描到但链表未见”视为待解释现象：可能是对象残留、对象损坏、版本问题或隐藏，必须进一步核验线程、地址空间和对象头。

## 待办

- [ ] 进程链表与对象扫描的交叉视图，以及孤儿/退出/隐藏进程的判定。
- [ ] 异常父子关系、令牌、句柄、线程起始地址与命令行。
- [ ] 用户态与内核态进程枚举差异的原因和误判边界。
