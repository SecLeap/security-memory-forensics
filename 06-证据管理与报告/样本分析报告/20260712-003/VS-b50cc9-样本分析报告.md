# VS-b50cc9 样本分析报告

> 报告状态：已完成基础静态分析与受控动态分析。分析依据包括 CAPA、PEStudio、Procmon、Noriben、INetSim 及用户提供的行为日志。结论基于当前证据链，不排除后续逆向分析修正。  

---

# 1. 案例信息

| 字段     | 内容                                                               |
| ------ | ---------------------------------------------------------------- |
| 案例编号   | VS-b50cc9-20260712                                               |
| 样本名称   | 20270612-003-b50cc9                                              |
| 样本来源   | VirusShare                                                       |
| SHA256 | B50CC9B20CC7CC42AB77E1FB589C6C633D00D26AAFAE739577D7B50A80BA3586 |
| MD5    | 81E1BE36D5AC581BE164BF89FE6943D0                                 |
| 文件大小   | 1,051,424 Bytes                                                  |
| 文件类型   | PE32 Executable                                                  |
| CPU架构  | x86 (32-bit)                                                     |
| 分析时间   | 2026-07-12                                                       |
| 分析环境   | Windows 11 + Procmon + Noriben + INetSim                         |

---

# 2. 执行摘要

## 核心结论

本样本并非典型木马、勒索软件或挖矿程序。

综合静态分析与动态行为证据表明：

```text
GetRightToGo Downloader
RegNow Download Manager
```

属于：

```text
商业软件下载器
安装器封装程序
数字河流（Digital River）下载管理组件
```

其主要功能为：

* 下载软件安装包
* 管理下载任务
* 保存配置文件
* 删除临时缓存
* 检测网络环境
* 获取系统信息

未发现：

* 持久化机制
* C2通信
* 恶意Payload释放
* 勒索行为
* 木马行为
* 挖矿行为

当前风险评级：

```text
低风险
```

---

# 3. HashMyFiles

## 获取到的信息

| 项目     | 值                                                                |
| ------ | ---------------------------------------------------------------- |
| MD5    | 81E1BE36D5AC581BE164BF89FE6943D0                                 |
| SHA1   | AC84F8656E4920D52BE45391A2633729836BF193                         |
| SHA256 | B50CC9B20CC7CC42AB77E1FB589C6C633D00D26AAFAE739577D7B50A80BA3586 |



---

# 4. PEStudio

## 基础信息

| 项目           | 值                       |
| ------------ | ----------------------- |
| Description  | RegNow Download Manager |
| Product      | GetRightToGo            |
| Compiler     | Visual Studio 2005      |
| Architecture | 32-bit                  |
| Subsystem    | GUI                     |
| Entropy      | 6.412                   |
| Overlay      | 11040 Bytes             |



---

## Manifest信息

发现：

```text
GetRightToGo
GetRightToGo.com Downloader
RegNow Download Manager
```



---

## 字符串

发现大量正常商业软件字符串：

```text
www.GetRightToGo.com
www.digitalriver.com
livemetrics.digitalriver.com
www.findfiles.com
www.softonic.com
```



说明其历史上用于：

```text
软件下载
下载统计
软件分发
```

---

# 5. Detect It Easy

## 编译信息

识别结果：

```text
Visual Studio 2005
PE32
x86
```

未发现：

```text
UPX
Themida
VMProtect
ASPack
PECompact
```

等常见壳。



---

# 6. CAPA分析

## ATT&CK映射

CAPA识别：

### Discovery

```text
T1082 系统信息发现
T1083 文件发现
T1016 网络配置发现
T1614 地理位置发现
```

### Defense Evasion

```text
T1497 沙箱检测
T1027 混淆
T1112 注册表修改
```

### Collection

```text
T1056 Keylogging
```

### Communication

```text
DNS
Socket
HTTP
```



---

## 重要说明

CAPA仅说明：

```text
样本具备相关代码能力
```

不代表：

```text
一定执行
一定恶意
```

例如：

```text
GetAsyncKeyState
SetWindowsHookEx
```

可能来自：

```text
下载器
GUI组件
第三方库
```

因此需要结合动态分析验证。

---

# 7. Procmon分析

## 文件行为

创建：

```text
%APPDATA%\GetRightToGo\
```

产生文件：

```text
20270612-003-b50cc9.data
20270612-003-b50cc9.data0
```

随后：

```text
WriteFile
```

最后：

```text
SetDispositionInformationEx
```

删除文件。

因此目录最终为空。

行为链：

```text
Create
↓
Write
↓
Use
↓
Delete
```

符合：

```text
下载器缓存
临时配置文件
```

行为特征。

---

# 8. Noriben分析

## 注册表行为

创建：

```text
HKCU\Software\Headlight\GetRightToGo
```

包括：

```text
CustomizedApps
SharedConfig
```

执行结束后：

```text
RegDeleteKey
```

全部清除。

说明：

```text
临时配置
非持久化
```



---

## BAM记录

发现：

```text
HKLM\...\Services\bam\
```

记录程序执行。

属于：

```text
Windows正常取证痕迹
```

不属于恶意行为。

---

# 9. INetSim分析

## DNS

样本执行期间主要看到：

```text
wpad.localdomain
dns.msftncsi.com
www.msftconnecttest.com
activity.windows.com
watson.events.data.microsoft.com
```

这些均为：

```text
Windows系统网络探测
```

包括：

### WPAD

```text
自动代理发现
```

### NCSI

```text
联网状态检测
```

### Telemetry

```text
系统遥测
```

---

## 未发现

未发现：

```text
恶意域名
随机域名
DGA域名
IP直连
```

未发现：

```text
HTTP下载Payload
HTTPS下载Payload
IRC
SMTP
```

通信。

---

# 10. 网络能力分析

CAPA显示：

```text
DNS Resolve
Socket Send
Socket Receive
HTTP Header
```



结合PEStudio发现：

```text
DigitalRiver
GetRightToGo
```

相关URL。

因此更符合：

```text
下载器网络能力
```

而非：

```text
C2通信框架
```

---

# 11. 反分析能力

发现：

```text
IsDebuggerPresent
NtGlobalFlag
GetTickCount
Mouse Activity Check
```



说明存在：

```text
基础反调试
基础反沙箱
```

能力。

但属于商业下载器常见设计。

---

# 12. IOC

## 文件

```text
SHA256
B50CC9B20CC7CC42AB77E1FB589C6C633D00D26AAFAE739577D7B50A80BA3586

MD5
81E1BE36D5AC581BE164BF89FE6943D0
```

---

## 注册表

```text
HKCU\Software\Headlight\GetRightToGo
```

---

## 文件路径

```text
%APPDATA%\GetRightToGo\
```

---

## URL

```text
http://www.getrighttogo.com/
http://www.digitalriver.com
http://livemetrics.digitalriver.com
```



---

# 13. 风险评估

| 项目   | 结论           |
| ---- | ------------ |
| 木马   | 未发现          |
| 勒索   | 未发现          |
| 挖矿   | 未发现          |
| 后门   | 未发现          |
| 持久化  | 未发现          |
| 键盘记录 | 静态存在能力，动态未验证 |
| 下载执行 | 存在           |
| 网络通信 | 存在           |
| 数据窃取 | 未发现证据        |
| C2通信 | 未发现证据        |

---

# 14. 最终结论

综合：

* PEStudio
* CAPA
* Procmon
* Noriben
* INetSim

多维证据分析结果：

```text
该样本本质为 GetRightToGo / RegNow Download Manager 下载器组件。
```

其主要行为为：

```text
创建临时配置
保存下载状态
检测网络环境
执行下载任务
清理缓存文件
删除临时注册表项
```

目前证据显示：

```text
未发现恶意载荷释放
未发现持久化
未发现远控通信
未发现恶意下载
未发现勒索行为
```

风险等级建议：

```text
低风险（Low）
```

建议作为：

```text
PUA（Potentially Unwanted Application）
商业下载器
软件下载管理组件
```

进行归档，而非直接归类为恶意软件。
