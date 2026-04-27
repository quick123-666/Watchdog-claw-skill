<!-- markdownlint-disable MD041 -->
<div align="center">

# Watchdog-claw-skill

_轻量级进程健康监控 - 内存检测 + 卡死检测 + 自动修复_

[![PowerShell](https://img.shields.io/badge/PowerShell-%2353912?logo=powershell)](https://docs.microsoft.com/powershell/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Stars](https://img.shields.io/github/stars/quick123-666/Watchdog-claw-skill)](https://github.com/quick123-666/Watchdog-claw-skill/stargazers)

</div>

## 目录

- [功能](#功能)
- [特性](#特性)
- [快速开始](#快速开始)
- [检测原理](#检测原理)
- [配置](#配置)
- [输出说明](#输出说明)
- [目录结构](#目录结构)
- [常见问题](#常见问题)
- [许可](#许可)

---

## 功能

| 检查项 | 说明 | 自动修复 |
|--------|------|----------|
| 进程内存 | 进程内存超限 → 终止进程 | ✅ |
| 进程卡死 | CPU 30秒无变化 → 终止进程 | ✅ |
| 缓存膨胀 | 缓存目录大小超限 | 报警 |
| 日志堆积 | 日志目录大小超限 | 报警 |

---

## 特性

- **零依赖** - PowerShell 原生，单文件复制即用
- **卡死检测** - 独创 CPU 变化检测算法，识别假死进程
- **自动修复** - 可配置自动终止+重启
- **跨场景** - 支持 python/node/QClaw 等任意进程

---

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

### 定时任务（推荐）

```powershell
# 每5分钟自动检测
schtasks /create /tn "Watchdog" /tr "powershell -ExecutionPolicy Bypass -File C:\path\to\watchdog.ps1 -Check" /sc MINUTE /mo 5 /f
```

---

## 检测原理

### 卡死检测

```
第一次运行 → 记录 CPU=100, Mem=500MB
                       ↓ 间隔31秒
第二次运行 → CPU=100.2, 增量=0.2% → 判定卡死 → 终止
```

1. 首次运行 `-Check` 记录进程 CPU 时间到临时文件
2. 下次运行时对比上次数据
3. **间隔 >30秒 且 CPU 增量 <0.5%** = 卡死进程
4. 自动终止并可配置重启

---

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
| `maxMemoryMB` | 内存超限阈值(MB) | 1024 |
| `cpuHangSeconds` | 卡死判定间隔(秒) | 30 |
| `minMemToCheckHang` | 卡死检测内存下限(MB) | 100 |
| `processWhitelist` | 监控的进程名列表 | python,node |
| `maxCacheMB` | 缓存目录超限(MB) | 1024 |
| `maxLogMB` | 日志目录超限(MB) | 100 |
| `autoKill` | 超限自动终止 | true |
| `autoRestart` | 终止后自动重启 | false |

---

## 输出说明

| 标记 | 含义 |
|------|------|
| `[INFO]` | 检查信息 |
| `[OK]` | 系统健康 |
| `[ISSUE]` | 发现问题 |
| `[FIX]` | 自动修复中 |
| `[WARN]` | 需手动处理 |
| `[ERROR]` | 修复失败 |

---

## 目录结构

```
Watchdog-claw-skill/
├── README.md              # 本说明
├── watchdog.ps1           # 主脚本
├── watchdog-config.json    # 配置文件
└── logs/                 # 日志目录
    └── watchdog.log
```

---

## 常见问题

### Q: 如何添加自定义监控进程？
A: 编辑 `watchdog-config.json`，修改 `processWhitelist` 数组。

### Q: 为什么不检测所有进程？
A: 为避免误杀系统进程，仅检测白名单中的进程。

### Q: 卡死检测需要运行两次吗？
A: 是的，首次记录基线，再次才能对比判断。

---

## 许可

MIT License - 详见 [LICENSE](LICENSE)

---

<div align="center">

如果你觉得好用，欢迎 ⭐ star！

</div>