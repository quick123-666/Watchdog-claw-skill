# Watchdog-claw-skill

> 轻量级进程健康监控 - 内存检测 + 卡死检测 + 自动修复

## 对比其他项目

| 特性 | 本项目 | ProcessWatch/agent | openclaw-watchdog | EventMonitor |
|------|--------|------------------|------------------|--------------|
| 语言 | PowerShell | Go | PowerShell | PowerShell |
| 依赖 | **无** | 需编译 | 无 | 无 |
| 安装 | **复制即可** | npm install | npm install | PS模块 |
| 卡死检测 | ✅ | ❌ | ❌ | ❌ |
| 内存检测 | ✅ | ✅ | ✅ | ❌ |
| 自动修复 | ✅ | ✅ | ✅ | ❌ |
| TUI界面 | ❌ | ✅ | ❌ | ❌ |
| 通知 | ❌ | Discord | ❌ | 应用洞察 |

**我们的优势**: 零依赖、单文件、检测卡死、自动修复

## 功能

| 检查项 | 说明 | 自动修复 |
|--------|------|---------|
| 进程内存 | 超限 → 终止 | ✅ |
| 进程卡死 | CPU 30秒无变化 → 终止 | ✅ |
| 缓存膨胀 | 目录超限 → 报警 | - |
| 日志堆积 | 目录超限 → 报警 | - |

## 快速开始

```powershell
# 克隆
git clone https://github.com/quick123-666/Watchdog-claw-skill.git
cd Watchdog-claw-skill

# 一次性检查
powershell -ExecutionPolicy Bypass -File watchdog.ps1 -Check

# 检查 + 自动修复
powershell -ExecutionPolicy Bypass -File watchdog.ps1 -Action
```

## 检测原理

**卡死检测**（独有特色）:
1. 首次运行 `-Check` 记录进程 CPU/内存到临时文件
2. 下次运行对比上次数据
3. **间隔 >30秒 且 CPU 增量 <0.5%** = 卡死

```powershell
# 每5分钟定时检测
schtasks /create /tn "Watchdog" /tr "powershell -ExecutionPolicy Bypass -File watchdog.ps1 -Check" /sc MINUTE /mo 5 /f
```

## 配置

编辑 `watchdog-config.json`:

```json
{
    "maxMemoryMB": 1024,
    "cpuHangSeconds": 30,
    "processWhitelist": ["python", "streamlit", "node", "QClaw"],
    "autoKill": true,
    "autoRestart": false
}
```

## 输出

- `[OK]` - 系统健康
- `[ISSUE]` - 发现问题
- `[FIX]` - 自动修复中

## 日志

`logs/watchdog.log`

---

MIT License