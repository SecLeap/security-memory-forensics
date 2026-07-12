# ProcDOT 详细实战手册

> 适用范围：隔离 Windows 11 实验虚拟机中，对已授权测试产生的 Procmon、PCAP/文本网络摘要和进程关系数据进行离线可视化关联。ProcDOT 是日志关系图工具，不采集内存、不替代 PML/PCAP/服务端日志，也不证明节点间存在因果关系或恶意性。

[ProcDOT 官方下载页](https://www.procdot.com/downloadprocdotbinaries.htm)提供 Windows/Linux 二进制及随附 readme；官方明确提示它依赖第三方软件，并要求按该版本 readme 完成配置。参考文章以 Procmon CSV 和 Wireshark 导出的文本输入构建进程—文件—注册表—网络关系图；本手册保留这一思路，但将关系图定位为“待复核假设图”，所有结论回到原始 PML、PCAP、服务端日志与 Volatility/MemProcFS 内存对象验证。

## 获取与安装

1. 仅从 ProcDOT 官方下载页或经验证的内部软件库获取 Windows 发布包。保存原始压缩包至 C:\Lab\Installers\ProcDOT\，记录下载 URL、版本/构建号、下载时间、许可证、压缩包 SHA-256 和页面/随附 changelog 信息。
2. 官方页面列有旧版本，且部分历史构建明确标注“Do not use”。默认只选择当前稳定发布；如因案件复现必须使用历史版本，应单独记录理由、风险、哈希和 VM 快照。
3. 解压至 C:\Lab\Tools\ProcDOT\。第三方依赖（常见为图布局/图形组件）只按照**该发布包随附 readme**安装与配置；不从错误提示、网盘或第三方 DLL 站点补文件。
4. 对 ProcDOT 主程序、关键依赖和配置文件生成 SHA-256 清单。先用自建、无害的最小 Procmon CSV 和网络文本样例验证能加载、筛选、刷新图并导出报告。
5. 仅在断网、快照后的分析 VM 使用。不要把样本、生产日志、PML、PCAP、关系图或 IP/域名自动上传到云服务或信誉查询服务。

    Get-FileHash 'C:\Lab\Installers\ProcDOT\<发布包>' -Algorithm SHA256
    Get-ChildItem 'C:\Lab\Tools\ProcDOT' -Recurse -File |
      Get-FileHash -Algorithm SHA256 |
      Export-Csv 'C:\Lab\Tools\ProcDOT\ProcDOT-工具-SHA256.csv' -NoTypeInformation -Encoding utf8

ProcDOT 或其图形依赖出现安全软件告警时，先复核官方来源、哈希、签名（如有）和隔离范围；不要在生产主机建立永久排除，也不要以关闭防护作为安装步骤。

## 案例目录与证据边界

    C:\Lab\Cases\LAB-001\
    ├─ 01-动态原始记录\
    │  ├─ Procmon\LAB-001.pml
    │  ├─ Procmon\LAB-001.csv
    │  ├─ Network\LAB-001.pcapng
    │  ├─ Network\LAB-001-procdot-input.txt
    │  └─ ServiceLogs\
    ├─ 02-ProcDOT\
    │  ├─ 00-输入工作副本\
    │  ├─ 01-项目与配置\
    │  ├─ 02-图形导出\
    │  ├─ 03-节点与边清单\
    │  └─ 04-筛选记录\
    └─ 04-内存镜像与输出\

必须分别保存原始 PML、原始 PCAPNG、服务端日志和它们供 ProcDOT 使用的派生输入。每项记录包含输入 SHA-256、来源工具/版本、捕获网卡或 Procmon 过滤器、UTC/本地时区、开始结束时间、转换命令或 GUI 操作、目标 PID/进程树范围与操作人。

关系图导出、截图、节点清单、筛选条件、项目文件均为分析派生物；不能覆盖或替代原始 PML/PCAP。每条图中的关键边都要建立“图元素 → 原始记录行/包号/服务日志行 → 内存对象”的引用链。

## 实验数据采集准备

只对自建无害程序、公开教学材料或明确获授权的实验对象执行动态观察。样本运行与内存采集按本仓库隔离环境和采集手册执行；ProcDOT 只处理已保存的日志副本。

### 1. Procmon

1. 实验前启动 Process Monitor，停止捕获并清空历史事件；仅保留目标 PID/进程树以及必要的 Process Create、File、Registry、Network 操作。
2. 在过滤器和显示列中保留 Process Name、PID、Operation、Path、Result、Detail、Time of Day。参考文章建议保留 Thread ID、取消显示序列号，并启用已解析网络地址；这些设置应按案例记录，不能替代 PID/时间。
3. 启动测试前再开始捕获；测试结束后立即停止并保存原始 PML。
4. 从同一 PML 导出一份 CSV 作为 ProcDOT 输入，记录导出时的列、过滤器、时间格式和 PML SHA-256。不要只保留 CSV。

### 2. 网络记录

1. Wireshark 仅抓取实验虚拟网络卡，保存原始 PCAPNG、接口、捕获/显示过滤器、起止时间和时区。
2. ProcDOT 所需的网络文本输入以当前版本 readme/导入向导为准。参考文章使用 Wireshark 导出的文本；转换前先复制 PCAPNG，输出至 Network 目录并记录 Wireshark 版本、导出格式、字段、显示过滤器和输入/输出哈希。
3. 不能加载或转换时，保留 PCAPNG 并用 Wireshark、Timeline Explorer 手工对齐；不通过伪造字段、编辑包时间或丢弃失败行来让 ProcDOT“接受”文件。

### 3. 内存镜像时间锚点

记录内存采集开始、结束、文件关闭和 SHA-256；统一转换为 UTC。关系图只能帮助缩小“应在镜像中查找什么、哪个 PID、哪个时间窗”，而内存对象存在与否仍由 Volatility 3/MemProcFS 的原始输出决定。

## 使用方法

### 1. 导入前检查

1. 检查 PML、PCAPNG 与所有派生输入均已停止写入；对原件和工作副本计算 SHA-256。
2. 确认 Procmon CSV 中含可关联的 PID、时间、操作、路径/网络字段；确认网络文本含时间、源/目的地址与端口、协议等当前导入器需要的字段。
3. 在 04-筛选记录 创建输入清单，列出：输入文件、哈希、来源、时区、时间精度、目标 PID、已知父进程、ProcDOT 版本与依赖版本。
4. 仅将 00-输入工作副本导入 ProcDOT。导入报错、空图、字段缺失或解析警告必须保存截图/日志，不可忽略。

### 2. 构建进程—行为—网络关系图

参考文章的最小流程可概括为：选择 Procmon CSV → 确定目标进程及其进程树范围 → 导入经记录的网络文本输入 → 应用可复现筛选 → 刷新图形。实际按钮名、输入格式和导入选项以**当前安装版本本机 readme/界面**为准。

1. 选择案例 Procmon CSV 工作副本，先确认导入时间范围、进程数量和解析警告。
2. 以 PID、创建时间、映像路径和父子关系确认目标进程；不要只按同名进程选择，避免把后台同名进程并入。
3. 载入对应时间窗的网络文本派生物。若多个进程共享连接，保留不确定性；网络记录到 PID 的映射必须由 Procmon 网络事件、进程时间线或其他独立证据支持。
4. 先以狭窄时间窗生成初始图，再逐步放宽至父进程、子进程、文件、注册表和网络节点。每次修改范围均另存项目/配置并记录。
5. 点击刷新/生成图后，保存图形截图、项目配置、节点/边导出（版本支持时）和生成日志；图文件名包含案例号、PID、UTC 时间窗和输入短哈希。

建议命名：

    LAB-001_pid1234_20260712T010000Z-20260712T011500Z_ProcDOT.png
    LAB-001_pid1234_ProcDOT-输入清单.csv
    LAB-001_pid1234_ProcDOT-边复核表.csv

### 3. 阅读图形与回查原始证据

| 图元素 | 可作为什么线索 | 必须回查 | 不可直接结论 |
| --- | --- | --- | --- |
| 进程/子进程节点 | PID、父子进程、映像路径、观察时间 | Procmon Process Create、进程树、Volatility pslist/psscan/cmdline | 创建关系必然由目标程序恶意触发 |
| 文件节点/边 | 某 PID 的文件操作候选 | PML 原始行、Operation、Result、Detail、路径与时间 | 文件一定成功写入、加载或执行 |
| 注册表节点/边 | 某 PID 的注册表操作候选 | PML RegCreateKey/RegSetValue 等原始行；Regshot 差异 | 已形成持久化或键值一定生效 |
| 网络节点/边 | 在时间窗内的地址/端口/协议关联线索 | PCAPNG 包号、会话、服务端日志、Procmon 网络记录 | 已真实外连、地址信誉或恶意归因 |
| 图的相邻/连线 | 待验证的时间与实体关联 | 所有相关原始输入与统一 UTC 时间 | 连线就是因果、数据流或执行链 |

对每条报告中的关键边建立边复核表：

    图文件/节点：<节点名称或内部标识>
    输入：<Procmon CSV / 网络文本>；SHA-256：<hash>
    原始证据：PML 行/过滤条件=<...>；PCAPNG 包号/流=<...>；服务日志行=<...>
    时间：原始=<...>；UTC=<...>；精度=<...>
    内存复核：镜像 SHA-256=<...>；Volatility/MemProcFS 命令=<...>；PID/VAD/对象=<...>
    状态：仅图线索 / 已由原始日志复核 / 已由内存上下文支持 / 已排除

## 与内存取证的联合使用

### 场景一：ProcDOT 锁定目标 PID，内存镜像验证对象

1. 从图中选择时间窗内的目标 PID、子进程、可疑路径和网络端点；不要先把整张图写成结论。
2. 在 Volatility 3/MemProcFS 输出中回查 PID、创建/退出时间、命令行、模块、VAD、线程、socket/连接对象和文件对象（适用时）。
3. 如需导出候选对象，记录镜像 SHA-256、插件/命令、对象地址、VAD 范围、导出物 SHA-256；再交给 PE-bear、DiE、FLOSS 等静态工具。
4. 对齐图形时间、PML/PCAP 时间与采集时间，明确哪些观察发生在快照前、采集中或之后。

完成标准：每个写入报告的关系都含至少一份原始 PML/PCAP/服务端记录，并在需要时含相应内存对象来源；缺少任一项时，以“ProcDOT 关系图线索”表述。

### 场景二：文件/注册表活动与进程内存

ProcDOT 图提示某 PID 对路径或键值存在操作时，先回查 PML 的 Operation、Result、Detail、时间和 PID；再以 Regshot 观察前后差异或以 Volatility 的进程/VAD/模块上下文解释。图中显示文件或注册表边并不能证明写入成功、持久化生效，或该内容仍在内存中。

### 场景三：网络节点与内存网络对象

图中出现的地址、域名或端口必须回查 PCAPNG/模拟服务日志；仅在隔离环境记录受控通信。再检查镜像中可能的对应进程和网络对象，注意连接关闭、扫描时间差、NAT、代理和 DNS 缓存会造成不一致。绝不通过在线信誉查询或真实联网来“验证”图节点。

## 常见问题与排错

| 现象 | 处理方式 |
| --- | --- |
| 工具启动失败或缺少组件 | 核对当前发布包 readme、工具/依赖哈希与隔离 VM；不从第三方 DLL 站下载组件 |
| 导入 CSV 后没有目标 PID | 检查 PML 是否在测试前清空、导出过滤器/列、PID 是否复用、时间窗和工作副本哈希 |
| 网络输入无法解析 | 按本机 readme 确认导出格式；保留原始 PCAPNG 与失败日志，改用 Wireshark/Timeline Explorer 对齐 |
| 图过于庞大 | 从单 PID、短 UTC 时间窗和关键操作类型开始；分阶段另存项目，不删除原始输入行 |
| 图的网络边与 PCAP 不一致 | 回查时区、接口、捕获过滤器、地址解析、NAT/代理和包号；记录差异，不强行合并 |
| 图中显示写入但 PML 为失败 | 以 PML 的 Result/Detail 为准，图只保留为关联线索 |
| 想上传 IP/样本查询信誉 | 停止；案例数据外传需要单独授权，本手册默认不进行 |

## 实战检查清单

- [ ] 已核验官方 ProcDOT 发布包、版本、主程序/依赖哈希与随附 readme。
- [ ] 仅在隔离、快照后的 VM 运行，且只导入案例工作副本。
- [ ] 已保存原始 PML、PCAPNG、服务端日志及其供 ProcDOT 使用的派生输入。
- [ ] 已记录 Procmon/网络捕获过滤器、导出格式、时区、目标 PID 与输入 SHA-256。
- [ ] 每次图形生成均保留项目/配置、截图或导出、时间窗、筛选条件和输出哈希。
- [ ] 每条关键图边已回查原始 PML/PCAP/服务端日志，并写入边复核表。
- [ ] 内存关联已记录镜像 SHA-256、Volatility/MemProcFS 命令、PID、VAD/模块/对象与采集时点。
- [ ] 未将图的连线、空间相邻或单个节点直接描述为因果、数据流、恶意性或真实外连。

## 资料

- [ProcDOT 官方下载与版本说明](https://www.procdot.com/downloadprocdotbinaries.htm)
- [ProcDOT 官方安装说明](https://www.procdot.com/installation.htm)
- [参考：使用 ProcDot 进行恶意软件分析](https://cloud.tencent.com/developer/article/2350803)
