# Eric Zimmerman 工具（Timeline Explorer）实战手册

> 适用范围：隔离 Windows 11 分析环境中，使用 Eric Zimmerman Tools 的 Timeline Explorer 对 Volatility、MemProcFS、Procmon、FakeNet-NG、Wireshark 摘要和其他**已导出的 CSV/XLSX**进行排序、过滤、分组与时间窗对齐。它是分析输出查看器，不解析内存镜像，不替代 Volatility/MemProcFS 的原始命令输出，也不证明事件归因。

[Eric Zimmerman Tools 官方工具页](https://ericzimmerman.github.io/#other-tools)列出 Timeline Explorer 及其他取证/辅助工具，并说明 Timeline Explorer 用于查看、过滤、分组和排序 CSV、Excel 文件。当前 GUI 工具采用 .NET 9；页面还提供全量自动下载脚本，但本仓库只安装案例所需的 Timeline Explorer，不使用该脚本批量下载无关工具，也不将其他工具扩展为本仓库的常规取证范围。

本手册合并并替代原“Timeline Explorer 安装实战手册”的安装、验证、使用和内存取证联动内容。

## 获取与安装

1. 只从 Eric Zimmerman Tools 官方页面的 Timeline Explorer 下载入口获取发布包。保留原始压缩包至 C:\Lab\Installers\Zimmerman\TimelineExplorer\，记录下载 URL、工具版本、发布日期、下载时间、许可证、文件名和 SHA-256。
2. 官方页说明 GUI 工具需要 .NET 9 Desktop Runtime；安装运行时前记录运行时来源、版本和安装包哈希。只在隔离分析 VM 安装，切勿在生产终端为方便查看案例文件而安装。
3. 将 Timeline Explorer 解压至 C:\Lab\Tools\TimelineExplorer\。不要从 Program Files 目录运行，也不要使用第三方整合包、镜像站、历史单文件替代品或全量自动下载脚本。
4. 官方页说明工具带有数字签名。应检查发布包/主程序的签名发布者和 SHA-256，并记录验证时间；签名或哈希不匹配时停止使用。
5. 使用自建无害 CSV 验证可打开、筛选、排序和导出；不要以未知样本、真实生产日志或尚在写入的 PML/PCAP 作为安装验证材料。

    Get-FileHash 'C:\Lab\Installers\Zimmerman\TimelineExplorer\<发布包>' -Algorithm SHA256
    Get-ChildItem 'C:\Lab\Tools\TimelineExplorer' -Recurse -File | Get-FileHash -Algorithm SHA256
    Get-AuthenticodeSignature 'C:\Lab\Tools\TimelineExplorer\<Timeline Explorer 主程序>.exe' |
      Format-List Status,StatusMessage,SignerCertificate

若当前运行时或工具版本不同于案例开始时的版本，先冻结旧版输出、记录变更，再在独立 VM 快照中重新验证。工具的显示、类型推断、时区处理和导出格式可能随版本变化。

## 证据准备与目录

    C:\Lab\Cases\LAB-001\
    ├─ 02-时间线\
    │  ├─ 00-原始输入\              # 原始 CSV/XLSX，只读
    │  ├─ 01-工作副本\              # Timeline Explorer 打开的副本
    │  ├─ 02-筛选导出\              # 只读分析派生物
    │  ├─ 03-筛选条件\              # 字段、过滤、排序、分组记录
    │  └─ 04-截图\
    ├─ 03-Volatility-原始输出\
    └─ 04-内存镜像与输出\

每次导入记录：案例号、输入来源工具和版本、输入 SHA-256、生成命令/过滤器、原始时区、时间字段名、UTC 偏移、是否已做格式转换、Timeline Explorer 版本/主程序哈希、操作人和查看时间。原始 CSV/XLSX 只读保存；所有筛选、排序或导出都在工作副本与派生目录中进行。

## 输入范围与时间规则

| 输入类型 | 可用于回答的问题 | 必须保留的来源 | 不可推断的内容 |
| --- | --- | --- | --- |
| Volatility 3 CSV/文本转表格 | 进程、模块、VAD、网络对象在分析输出中的列值与时间字段 | 镜像哈希、插件、完整命令、原始输出 | 对象实际发生时间或持续时间 |
| MemProcFS 导出 CSV | VFS/对象导出清单、进程或模块关联线索 | 镜像哈希、版本、挂载参数、原始目录 | 导出物一定等同原始磁盘文件 |
| Procmon CSV | 文件/注册表/进程事件的观察顺序 | 原始 PML、过滤条件、时区、PID | 单凭事件窗口确定内存中仍存在对象 |
| FakeNet-NG/服务端日志 | DNS、HTTP、模拟服务请求的服务端时间 | 服务配置、日志原件、时区、请求标识 | 真实外部网络通信 |
| Wireshark 导出摘要 | 包/会话的相对时间、五元组、协议字段 | 原始 PCAPNG、显示过滤器、接口、时区 | 没有 PCAP 的完整内容或 PID 归因 |

时间字段必须先统一。默认将所有可转换字段规范为 UTC，并保存原始时区/原始列；若来源只含本地时间、相对时间或未标时区时间，明确标注“不确定”，不要自行假定其为 UTC。不要把 Timeline Explorer 的行显示顺序当作事件的精确因果顺序。

## 使用方法

### 1. 打开前的完整性与字段盘点

1. 确认输入文件已经由产生工具关闭；计算输入 SHA-256，再复制至 01-工作副本。
2. 在 03-筛选条件 中建立字段字典：来源文件、每个时间列含义、时区、PID、进程名、路径、五元组、事件类型和唯一关联键。
3. 通过 Timeline Explorer 打开工作副本。观察工具是否将时间、数字、空值和文本正确识别；不要在原始输入上直接覆盖保存。
4. 保存初始视图截图，包含文件名、列名、行数、工具版本与当前排序列；将不能识别、缺失或格式异常的列记录为数据质量问题。

### 2. 排序、过滤、分组与导出

1. 先按规范化 UTC 时间升序排序；将原始时间列保留在相邻位置，避免失去时区解释。
2. 用 PID、进程树标识、路径、事件类别、域名、五元组或 Volatility 对象标识建立**窄过滤**。每次过滤都记录字段、比较运算、值、大小写/空值处理和生成时间。
3. 需要看重复/聚集现象时，按进程、路径、域名或事件类型分组；分组计数是辅助视图，仍需回到原始行和原始日志复核。
4. 将筛选结果导出至 02-筛选导出，文件名含案例号、来源、UTC 时间窗和短哈希；导出后计算哈希。
5. 在 03-筛选条件 保存可重放记录，包括输入哈希、工具版本、列映射、排序列、筛选表达式、分组字段、导出路径和截图。

建议记录模板：

    输入：LAB-001-procmon.csv；SHA-256：<hash>
    来源：Procmon PML=<hash>；过滤器=<规则>
    时间：Operation Time，原始时区=UTC+08:00，规范化=UTC
    Timeline Explorer：<版本>；主程序 SHA-256=<hash>
    排序：UtcTime 升序
    筛选：PID=1234；Operation 属于 RegSetValue, CreateFile
    导出：LAB-001-pid1234-<时间窗>.csv；SHA-256=<hash>

不要使用 Timeline Explorer 对案例输入执行编辑、覆盖保存、删除行或替换原始时间。若必须做字段规范化，保留原始列、转换规则和输入/输出哈希，并将其作为单独派生物。

### 3. 内存采集时间窗对齐

1. 从采集记录获得内存采集开始、结束和文件关闭时间，转换为 UTC 后添加到时间线工作副本的“分析标记”表中；不将标记写回原始日志。
2. 将 Procmon、PCAP/服务端日志和静态导出物记录按同一 UTC 标准排序，筛选采集前、采集中、采集后窗口。
3. 对采集前的重点 PID、路径、模块或网络线索，在 Volatility 3/MemProcFS 的原始输出中查找对应对象；记录命令、对象地址/VAD、模块基址或文件对象。
4. 对采集后出现的事件，只能说明它不在该快照的时间窗口内；不能用一个镜像否定之后发生的变化。

| 时间线观察 | 内存分析复核 | 结论边界 |
| --- | --- | --- |
| PID 在采集前有文件/注册表事件 | pslist/psscan、cmdline、VAD、模块、句柄等适用插件 | 支持“该 PID 在事件记录中出现，快照中对象需另行确认” |
| 域名/连接在采集窗口附近 | 网络对象、进程、PCAP/FakeNet-NG 原始记录 | 不能由 CSV 行直接确定真实外连或 PID 归因 |
| 路径对应的疑似模块/导出物 | 模块列表、VAD、文件对象、导出命令和哈希 | 不同哈希需检查版本、截断、映射和采集时点 |
| 快照中存在可疑 VAD | Timeline Explorer 回查同 PID 的时间窗事件 | VAD 存在不等于某一日志事件造成它 |

## 典型实战场景

### 场景一：进程—文件/注册表—内存镜像闭环

1. 以 Procmon 原始 PML 导出受控 CSV，保留 PML 哈希、过滤器和时区。
2. 在 Timeline Explorer 中以 PID 和 UTC 时间窗筛选 CreateFile、WriteFile、RegSetValue 等候选事件，导出结果与筛选条件。
3. 在 Volatility 3/MemProcFS 中用同一 PID 复核进程、命令行、模块、VAD 和文件对象；记录镜像哈希与完整命令。
4. 报告把“日志中观察到的操作”“快照中观察到的对象”“尚未建立因果关系”分为三类。

### 场景二：DNS/HTTP 模拟服务与内存采集时点

1. 保留 FakeNet-NG/服务端原始日志、PCAPNG 和对应配置；统一到 UTC。
2. 在 Timeline Explorer 按域名、URI、五元组与时间窗口过滤，导出关联行。
3. 在内存输出中检查相应 PID、网络对象、命令行及字符串/配置线索；若缺少原始 PCAP 或服务端日志，不把摘要表作为唯一网络证据。
4. 结论只写明受控环境中的观察结果，不外推至真实互联网通信。

### 场景三：多个分析输出的时间字段质量检查

将每份输入的时间字段类型、时区、最早/最晚值、空值比例和解析异常记入字段字典。发现夏令时、本地时间、相对时间或无时区值混用时，停止合并排序，先保留原始行并在报告中说明不能精确对齐。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| GUI 无法启动 | 核对 .NET 9 Desktop Runtime、工具版本、签名和哈希；在隔离 VM 修复运行时，不从第三方补 DLL |
| CSV 打开后时间列不正确 | 回查原始列格式、区域设置、时区和分隔符；保留原始列，建立转换派生物而非覆盖 |
| 行数/字段缺失 | 检查 CSV 导出命令、编码、分隔符、过滤器和工具错误；以原始 PML/PCAP/Volatility 输出复核 |
| 排序后因果关系不清 | 记录时间精度、时区和采集窗口；不能凭同一秒或相邻行断言因果 |
| 导出结果与视图不一致 | 保存截图、版本、筛选条件与导出哈希；在新工作副本复现，保留两份结果 |
| 想通过 Get-ZimmermanTools 下载所有工具 | 不在本仓库流程中使用；只下载 Timeline Explorer，避免引入无关工具与版本漂移 |

## 实战检查清单

- [ ] 已从官方入口获取 Timeline Explorer，并记录发布包、主程序、签名和 SHA-256。
- [ ] 已在隔离 VM 配置所需 .NET 9 Desktop Runtime，未用全量自动下载脚本或第三方包。
- [ ] 原始 CSV/XLSX 只读保留；工作副本、筛选导出、条件记录和截图均在案例目录。
- [ ] 已为每个时间列记录含义、原始时区、UTC 规范化规则和精度限制。
- [ ] 每个导出结果均有输入哈希、筛选/排序/分组条件、工具版本和自身 SHA-256。
- [ ] 内存关联已保留镜像哈希、Volatility/MemProcFS 命令、PID、对象地址/VAD/模块等来源。
- [ ] 未将时间线相邻性、行顺序或单一 CSV 摘要直接表述为行为因果或归因。

## 官方资料

- [Eric Zimmerman Tools 官方页面](https://ericzimmerman.github.io/)
- [Timeline Explorer 官方下载入口](https://ericzimmerman.github.io/#other-tools)
