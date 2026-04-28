# skill: 项目分析

> 启动词: "看看这个" 或 提供项目/项目链接
> 分析项目结构、代码统计、模块关系

## 功能

- 统计文件数量、代码行数
- 分析模块/目录结构
- 查找函数、类、导入关系
- 生成项目概览

## 使用

当用户说"看看这个"或提供项目路径时：

```bash
# 1. 列出所有文件
Get-ChildItem -Recurse -File | Select-Object Extension, FullName

# 2. 统计代码行数
Get-Content *.py | Measure-Object -Line

# 3. 查找函数定义
Select-String -Pattern "^def |^class " -Recurse

# 4. 分析导入
Select-String -Pattern "^import |^from " -Recurse
```

## 输出格式

```
项目: {path}
文件: {fileCount}
代码行: {lineCount}
模块: {moduleCount}
语言: {langs}
```

## 示例

```
项目: C:\Users\Administrator\Desktop\skills-main
文件: 390
代码行: ~15000
模块: 8 (xlsx, docx, pptx, frontend-design, web-artifacts-builder, skill-creator, theme-factory, slack-gif-creator)
语言: Python, JavaScript, HTML, CSS
```

## 依赖

- PowerShell
- 无需额外安装