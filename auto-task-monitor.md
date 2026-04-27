# Auto Task Monitor - 自动任务检查

> 检查所有自动运行的项目和定时任务状态

## 触发词
- 检查自动任务
- 检查定时任务
- 哪些在自动运行
- 监控状态
- task monitor

## 功能

### 1. 检查 Windows 定时任务
列出所有 Mercury/TuriX 相关的定时任务：

```bash
schtasks /query /fo csv | Select-String -Pattern "Mercury|TuriX|auto"
```

### 2. 检查任务详情
查看特定任务状态：

```bash
schtasks /query /tn "MercuryCrabAutoSave" /fo list /v
```

### 3. 测试 auto_save.py
手动触发测试：

```bash
python "C:\Users\Administrator\Mercury-Crab-Deploy\skills\hermes-learning\auto_save.py" "手动测试"
```

### 4. 检查 ecloud 运营商任务
```bash
powershell -Command "Get-ScheduledTask -TaskName 'ecloud*' | Select-Object TaskName, State"
```

### 5. 检查进程
检查相关进程是否运行：
```bash
powershell -Command "Get-Process -Name 'python','node' -ErrorAction SilentlyContinue | Select-Object Name, Id"
```

## 输出格式

### 任务状态表
| 任务名 | 状态 | 上次运行 | 说明 |
|--------|------|---------|------|
| MercuryCrabAutoSave | Ready | 17:00 | 每2小时自动保存 |
| xxx | xxx | xxx | xxx |

### 检查结论
- ✅ 正常: 项目名称
- ⚠️ 需关注: 项目名称
- ❌ 失败: 项目名称

## 使用场景

1. **日常检查**: "检查自动任务状态"
2. **排查问题**: "为什么自动保存没运行"
3. **新增监控**: "帮我监控 X 程序"
4. **测试功能**: "测试 auto_save"

## 相关路径

- 自动保存脚本: `C:\Users\Administrator\Mercury-Crab-Deploy\skills\hermes-learning\auto_save.py`
- 知识库: `C:\Users\Administrator\Mercury-Crab-Deploy\knowledge\`
- 定时任务: `\MercuryCrabAutoSave`