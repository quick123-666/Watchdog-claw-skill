# Watchdog-claw-skill

> 轻量级进程健康监控 - 内存检测 + 卡死检测 + 自动修复

## 功能

| 检查项 | 说明 | 自动修复 |
|--------|------|---------|
| 进程内存 | 超限 → 终止进程 | ✅ |
| 进程卡死 | CPU 30秒无变化 → 终止进程 | ✅ |
| 缓存膨胀 | 目录大小超限 | 报警 |
| 日志堆积 | 目录大小超限 | 报警 |

## 特性

- **零依赖** - PowerShell 原生，单文件复制即用
- **卡死检测** - 独创 CPU 变化检测算法，识别假死进程
- **自动修复** - 可配置自动终止+重启
- **跨场景** - 支持 python/node/QClaw 等任意进程

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

### 卡死检测

1. 首次运行 `-Check` 记录进程 CPU 时间到临时文件
2. 下次运行时对比上次数据
3. **间隔 >30秒 且 CPU 增量 <0.5%** = 卡死

```
第一次运行 → 记录 CPU=100, Mem=500MB
                       ↓ 间隔31秒
第二次运行 → CPU=100.2, 增量=0.2% → 判定卡死 → 终止
```

### 定时任务

```powershell
# 每5分钟检测
schtasks /create /tn "Watchdog" /tr "powershell -ExecutionPolicy Bypass -File watchdog.ps1 -Check" /sc MINUTE /mo 5 /f
```

## 配置

编辑 `watchdog-config.json`:

```json
{
    "maxMemoryMB": 1024,
    "cpuHangSeconds": 30,
    "minMemToCheckHang": 100,
    "processWhitelist": ["python", "streamlit", "node", "QClaw"],
    "maxCacheMB": 1024,
    "maxLogMB": 100,
    "autoKill": true,
    "autoRestart": false,
    "restartCommands": {
        "QClaw": "Start-Process 'C:\\Program Files\\QClaw\\QClaw.exe'"
    }
}
```

| 参数 | 说明 | 默认值 |
|------|------|--------|
| maxMemoryMB | 内存超限阈值(MB) | 1024 |
| cpuHangSeconds | 卡死判定间隔(秒) | 30 |
| processWhitelist | 监控的进程名 | python,node |
| autoKill | 超限自动终止 | true |
| autoRestart | 终止后自动重启 | false |

## 输出说明

| 标记 | 含义 |
|------|------|
| `[INFO]` | 检查信息 |
| `[OK]` | 系统健康 |
| `[ISSUE]` | 发现问题 |
| `[FIX]` | 自动修复中 |
| `[WARN]` | 需手动处理 |
| `[ERROR]` | 修复失败 |

## 日志

日志文件: `logs/watchdog.log`

```log
[2026-04-27 18:30:23][INFO] 进程: 0 问题
[2026-04-27 18:30:23][OK] 系统健康
```

## 目录结构

```
Watchdog-claw-skill/
├── README.md              # 本说明
├── watchdog.ps1           # 主脚本
├── watchdog-config.json    # 配置文件
└── logs/                 # 日志目录
    └── watchdog.log
```

## 许可

MIT License