# Watchdog-claw-skill

> QClaw/TuriX 系统健康守护 - 监控进程内存、卡死检测、缓存/日志清理

## 功能

| 检查项 | 说明 | 自动修复 |
|--------|------|---------|
| 进程内存 | 白名单进程内存超限 → 终止 | ✅ |
| 进程卡死 | CPU 30秒无变化检测 → 终止 | ✅ |
| 缓存膨胀 | 缓存目录超限 → 报警 | - |
| 日志堆积 | 日志目录超限 → 报警 | - |

## 快速开始

```powershell
# 安装
git clone https://github.com/quick123-666/Watchdog-claw-skill.git

# 一次性检查
powershell -ExecutionPolicy Bypass -File watchdog.ps1 -Check

# 检查 + 自动修复
powershell -ExecutionPolicy Bypass -File watchdog.ps1 -Action
```

## 定时任务（每5分钟）

```powershell
schtasks /create /tn "Watchdog" /tr "powershell -ExecutionPolicy Bypass -File C:\path\to\watchdog.ps1 -Check" /sc MINUTE /mo 5 /f
```

## 检测原理

1. 首次运行 `-Check` 记录进程 CPU/内存到临时文件
2. 下次运行对比上次数据
3. **间隔 >30秒 且 CPU 增量 <0.5%** = 卡死
4. 自动终止并可配置重启

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

## 输出说明

- `[INFO]` - 正常检查
- `[OK]` - 系统健康
- `[ISSUE]` - 发现问题
- `[FIX]` - 正在修复
- `[WARN]` - 需手动处理

## 日志

`logs/watchdog.log`

---

MIT License