# Watchdog - 系统健康守护

> 监控进程内存、进程卡死、缓存膨胀、日志堆积，支持后台持续轮询和自动修复

## 触发词
- 健康检查
- 系统监控
- 进程监控
- watchdog
- healthcheck
- 系统自愈

## 运行模式

### 1. 一次性检查
```powershell
powershell -ExecutionPolicy Bypass -File "skills\watchdog.ps1" -Check
```

### 2. 后台持续轮询（推荐）
```powershell
# 启动后台轮询
Invoke-WatchdogJob -IntervalSeconds 60

# 停止后台轮询
Stop-WatchdogJob

# 查看状态
Get-WatchdogJob
```

## 核心功能

| 检查项 | 说明 | 自动修复 |
|--------|------|---------|
| 进程内存 | 白名单进程内存超限检测 | 终止进程 |
| 进程卡死 | CPU 连续无变化检测 | 终止进程 |
| 缓存膨胀 | 指定缓存目录大小超限 | 报警 |
| 日志堆积 | 日志目录大小超限 | 报警 |

## 配置

配置文件: `skills/watchdog-config.json`

```json
{
    "maxMemoryMB": 1024,
    "cpuHangSeconds": 30,
    "minMemToCheckHang": 100,
    "processWhitelist": ["python", "streamlit", "node", "QClaw"],
    "maxCacheMB": 1024,
    "maxLogMB": 100,
    "autoKill": true,
    "autoRestart": false
}
```

## 后台 Job 命令

```powershell
# 启动（每60秒检查一次）
Start-WatchdogJob -IntervalSeconds 60

# 停止
Stop-WatchdogJob

# 查看状态
Get-WatchdogJobStatus
```

## 日志

日志文件: `skills/logs/watchdog.log`

## 输出说明
- `[INFO]` - 正常检查信息
- `[OK]` - 系统健康
- `[ISSUE]` - 发现问题
- `[FIX]` - 正在修复
- `[WARN]` - 需手动处理
- `[ERROR]` - 修复失败