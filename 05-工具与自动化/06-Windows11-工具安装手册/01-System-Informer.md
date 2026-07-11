# System Informer 安装实战手册

## 获取与安装

从 [System Informer 官方项目](https://github.com/winsiderss/systeminformer/releases) 下载 Windows release；记录 ZIP/安装包哈希和发布标签。解压或安装至 `C:\Lab\Tools\SystemInformer`，首次运行时仅观察工具自身进程，不加载第三方插件。

## 验证与最小使用

1. 以管理员身份启动，确认版本和签名信息。
2. 对无害测试程序记录 PID、父进程、命令行、模块、线程、句柄和内存区域。
3. 导出或截图时写入案例编号与时间；不要直接结束、挂起或修改未理解的系统进程。

## 内存取证联动

记录 PID、模块基址和线程入口；在 Volatility 3 中以进程、DLL、VAD 和线程结果交叉验证。

## 使用方法

1. 在 **Processes** 中定位测试进程，记录 PID、父 PID、命令行与启动时间。
2. 进入进程属性的 Modules、Threads、Memory、Handles 页面，导出或截图异常项。
3. 对每个异常项登记“观察时间、对象地址/模块基址、路径、解释假设”；不执行终止、注入或内存编辑动作。

## 实战场景与完成标准

场景：无害测试程序访问 Debian 模拟 HTTP 服务时，记录其进程树、网络相关模块和线程入口。完成标准是 PID、模块基址和时间能在 Procmon、Wireshark 与 Volatility 输出中至少两两对应。
