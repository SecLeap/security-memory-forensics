# 内存结构与解析

## 学习方法

先用框架插件定位对象，再回到地址空间、页表、结构字段与原始字节验证。插件的空输出可能来自符号不匹配、镜像不完整、版本不支持或对象已回收，不能直接解释为“对象不存在”。

## Volatility 3 起步

Volatility 3 要求 Python 3.8+；Windows 所需符号可自动下载和缓存，Linux/macOS 通常需自行准备符号或用 `dwarf2json` 生成 ISF。详见[官方 README](https://github.com/volatilityfoundation/volatility3)与[符号表文档](https://volatility3.readthedocs.io/en/latest/symbol-tables.html)。

```bash
python -m pip install volatility3
vol -f <镜像路径> windows.info
vol -f <镜像路径> windows.pslist
vol -f <镜像路径> windows.pstree
```

对 Linux/macOS，先列出可用插件并验证符号/内核匹配，再运行对应的 `linux.*` 或 `mac.*` 插件。所有命令中的 `<镜像路径>` 都应为副本，原始镜像保持只读保存。

## 推荐资料

- [Volatility 3 基础概念](https://volatility3.readthedocs.io/en/latest/basics.html)：layer、template、object 与 symbol table。
- [Volshell](https://volatility3.readthedocs.io/en/latest/volshell.html)：在理解对象模型后做交互式验证。
- [Windows Debugger](https://learn.microsoft.com/windows-hardware/drivers/debugger/)：补充 Windows dump 格式和符号调试。

## 待办

- [ ] 物理内存、虚拟地址、页表、内核符号、调试信息和地址随机化。
- [ ] Windows 内核结构与 PDB；Linux vmlinux/BTF；macOS 内核结构。
- [ ] Volatility 3、MemProcFS 等框架的原理、插件模型和版本局限。
- [ ] 镜像身份识别、符号匹配、损坏镜像处理和结果可信度。
