# Process Explorer 安装实战手册

## 获取与安装

从 [Microsoft Process Explorer](https://learn.microsoft.com/sysinternals/downloads/process-explorer) 获取并解压至 `C:\Lab\Tools\Sysinternals\ProcessExplorer`；记录版本/哈希。与 System Informer 任选一个作为主进程观察器，避免重复操作。

## 验证与最小使用

启动无害测试程序后，记录进程树、命令行、加载 DLL、句柄和线程；保存案例时间点的导出或截图。不要用该工具关闭/挂起未知进程。

## 内存取证联动

将模块路径、PID、线程入口与 `windows.dlllist`、`windows.vadinfo` 和线程插件输出对齐。

## 使用方法

1. 在树形视图确认测试进程父子关系，再打开 Properties。
2. 在 Image、DLLs、Threads、Handles 页面记录命令行、模块路径、线程起始地址和关键句柄。
3. 导出/截图时注明 PID 和时间，避免只保存名称相同但 PID 已复用的进程记录。

## 实战场景与完成标准

场景：将测试程序加载的已知 DLL 与镜像模块列表对照。完成标准是解释模块基址不同是否来自 ASLR，且不以单一 DLL 列表作为异常结论。
