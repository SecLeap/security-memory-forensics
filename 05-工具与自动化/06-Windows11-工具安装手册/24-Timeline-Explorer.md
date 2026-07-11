# Timeline Explorer 安装实战手册

## 获取与安装

从 [Eric Zimmerman Tools 官方页](https://ericzimmerman.github.io/) 获取 Timeline Explorer，记录 release、哈希和许可证。解压至 `C:\Lab\Tools\TimelineExplorer`，不要使用第三方重打包版本。

## 验证与最小使用

对 Procmon CSV、服务端日志 CSV 或其他结构化实验输出进行查看；记录导入文件哈希、时区、排序/过滤条件和导出结果。

## 内存取证联动

时间线用于缩小内存采集前后的行为窗口；对象是否在镜像中可见仍由采集时刻和内存分析决定。

## 使用方法

1. 导入 Procmon CSV、服务端日志或网络摘要，先统一时区/时间格式。
2. 按 PID、五元组、路径或事件类型过滤，保存筛选条件和导出 CSV。
3. 将关键窗口与镜像采集开始/结束时间标注在同一时间线上。

## 实战场景与完成标准

场景：对齐 DNS、HTTP、文件写入与内存采集时刻。完成标准是报告可解释哪些行为发生在镜像之前、期间或之后。
