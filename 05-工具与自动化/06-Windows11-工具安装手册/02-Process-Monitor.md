# Process Monitor 安装实战手册

## 获取与安装

从 [Microsoft Process Monitor](https://learn.microsoft.com/sysinternals/downloads/procmon) 或 Sysinternals Suite 获取。它为便携式工具：解压至 `C:\Lab\Tools\Sysinternals\Procmon`，记录版本和发布包哈希。

## 验证与最小使用

1. 以管理员身份启动，立即停止捕获并清空初始事件。
2. 创建仅聚焦无害测试程序 PID/进程树的过滤器；把 PML 写入案例目录。
3. 启动测试前开始捕获，结束后立刻停止；同时导出 CSV，但必须保留原始 PML。

## 内存取证联动

以 PID、时间、文件/注册表路径为线索，在镜像中检查对应进程、命令行、句柄和模块。Procmon 事件不等于内存中仍存在同一对象。

## 使用方法

1. 用 `Process Name is <测试程序>` 或 PID 过滤；先排除已知噪声，再开始捕获。
2. 按时间查看 Process Create、Load Image、CreateFile、RegSetValue 等事件，打开事件属性记录完整路径和调用上下文。
3. 保存 PML、CSV 和过滤器；CSV 用于时间线，PML 用于复核。

## 实战场景与完成标准

场景：验证测试程序创建文件并加载模块的顺序。完成标准是报告给出 PID、事件时间、路径和模块名，并能在同一时段的进程/模块内存分析结果中解释其可见性或缺失原因。
