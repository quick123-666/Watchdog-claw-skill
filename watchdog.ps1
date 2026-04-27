# Watchdog - PowerShell 后台任务版

param(
    [switch]$Check,
    [switch]$Action,
    [switch]$StartJob,
    [switch]$StopJob,
    [switch]$Status,
    [int]$IntervalSeconds = 60,
    [string]$Config = "$PSScriptRoot\watchdog-config.json"
)

$script:JobName = "TuriXWatchdog"
$script:StateFile = "$env:TEMP\turiX-watchdog-job.json"

function Write-Log {
    param([string]$Level, [string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp][$Level] $Message"
    Write-Host $logLine
    $logDir = "$PSScriptRoot\logs"
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    Add-Content -Path "$logDir\watchdog.log" -Value $logLine -Encoding UTF8
}

function Load-Config {
    param([string]$Path)
    $defaultConfig = @{
        maxMemoryMB = 1024
        cpuHangSeconds = 30
        minMemToCheckHang = 100
        processWhitelist = @("python", "streamlit", "node", "QClaw")
        maxCacheMB = 1024
        maxLogMB = 100
        cachePaths = @("$env:USERPROFILE\.qclaw\compile-cache")
        logPaths = @("$env:USERPROFILE\.qclaw\logs")
        autoKill = $true
        autoRestart = $false
        restartCommands = @{ "QClaw" = "Start-Process 'C:\Program Files\QClaw\QClaw.exe'" }
    }
    if (Test-Path $Path) {
        try {
            $fileConfig = Get-Content $Path | ConvertFrom-Json
            foreach ($key in $fileConfig.PSObject.Properties) {
                $defaultConfig[$key.Name] = $key.Value
            }
        } catch { Write-Log "WARN" "配置加载失败: $_" }
    }
    return $defaultConfig
}

function Get-DirectorySizeMB {
    param([string]$Path)
    try {
        if (-not (Test-Path $Path)) { return 0 }
        $size = (Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        return [math]::Round(($size -or 0) / 1MB, 2)
    } catch { return 0 }
}

function Check-Processes {
    param($Config)
    $issues = @()
    $processes = Get-Process | Where-Object { $Config.processWhitelist -contains $_.Name }
    foreach ($proc in $processes) {
        $memMB = [math]::Round($proc.WorkingSet64 / 1MB, 2)
        if ($memMB -gt $Config.maxMemoryMB) {
            $issues += [PSCustomObject]@{
                Type = "memory"
                Process = $proc.Name
                PID = $proc.Id
                Value = $memMB
                Threshold = $Config.maxMemoryMB
                Message = "$($proc.Name)(PID:$($proc.Id)) 内存 ${memMB}MB > $($Config.maxMemoryMB)MB"
            }
        }
    }
    return $issues
}

function Check-Cache {
    param($Config)
    $issues = @()
    foreach ($cachePath in $Config.cachePaths) {
        $expandedPath = $ExecutionContext.InvokeCommand.ExpandString($cachePath)
        if (Test-Path $expandedPath) {
            $sizeMB = Get-DirectorySizeMB $expandedPath
            if ($sizeMB -gt $Config.maxCacheMB) {
                $issues += [PSCustomObject]@{
                    Type = "cache"
                    Path = $expandedPath
                    Value = $sizeMB
                    Threshold = $Config.maxCacheMB
                    Message = "缓存 $expandedPath ${sizeMB}MB > $($Config.maxCacheMB)MB"
                }
            }
        }
    }
    foreach ($logPath in $Config.logPaths) {
        $expandedPath = $ExecutionContext.InvokeCommand.ExpandString($logPath)
        if (Test-Path $expandedPath) {
            $sizeMB = Get-DirectorySizeMB $expandedPath
            if ($sizeMB -gt $Config.maxLogMB) {
                $issues += [PSCustomObject]@{
                    Type = "log"
                    Path = $expandedPath
                    Value = $sizeMB
                    Threshold = $Config.maxLogMB
                    Message = "日志 $expandedPath ${sizeMB}MB > $($Config.maxLogMB)MB"
                }
            }
        }
    }
    return $issues
}

function Check-ProcessHang {
    param($Config)
    $issues = @()
    $minMem = $Config.minMemToCheckHang
    
    $currentState = @{}
    $processes = Get-Process | Where-Object { $Config.processWhitelist -contains $_.Name }
    $now = Get-Date
    
    foreach ($proc in $processes) {
        $currentState[$proc.Id.ToString()] = @{
            Name = $proc.Name
            CPU = $proc.CPU
            MemMB = [math]::Round($proc.WorkingSet64 / 1MB, 2)
            Time = $now.ToString("o")
        }
    }
    
    $lastState = @{}
    if (Test-Path $script:StateFile) {
        try {
            $json = Get-Content $script:StateFile -Raw | ConvertFrom-Json
            foreach ($key in $json.PSObject.Properties) {
                $lastState[$key.Name] = $key.Value
            }
        } catch {}
    }
    
    foreach ($key in $currentState.Keys) {
        $curr = $currentState[$key]
        if ($lastState.ContainsKey($key) -and $curr.MemMB -gt $minMem) {
            $last = $lastState[$key]
            $lastTime = [datetime]$last.Time
            $timeDiff = ($now - $lastTime).TotalSeconds
            $cpuDiff = $curr.CPU - $last.CPU
            
            if ($timeDiff -gt $Config.cpuHangSeconds -and $cpuDiff -lt 0.5) {
                $issues += [PSCustomObject]@{
                    Type = "hang"
                    Process = $curr.Name
                    PID = [int]$key
                    Message = "$($curr.Name)(PID:$key) ${timeDiff}s 内 CPU 无变化，内存 $($curr.MemMB)MB"
                }
            }
        }
    }
    
    $currentState | ConvertTo-Json -Depth 2 | Set-Content $script:StateFile -Encoding UTF8
    return $issues
}

function Invoke-Fix {
    param($Issues, $Config)
    foreach ($issue in $Issues) {
        Write-Log "FIX" "处理: $($issue.Message)"
        if ($issue.Type -in @("memory", "hang") -and $Config.autoKill) {
            try {
                Stop-Process -Id $issue.PID -Force -ErrorAction SilentlyContinue
                Write-Log "OK" "已终止 $($issue.Process)(PID:$($issue.PID))"
            } catch { Write-Log "ERROR" "终止失败: $_" }
        }
        if ($issue.Type -in @("cache", "log")) {
            Write-Log "WARN" "需手动清理: $($issue.Path)"
        }
    }
}

function Run-Check {
    param($Config, [switch]$Action)
    $allIssues = @()
    
    $p = Check-Processes $config
    $allIssues += $p
    
    $c = Check-Cache $config
    $allIssues += $c
    
    $h = Check-ProcessHang $config
    $allIssues += $h
    
    if ($allIssues.Count -gt 0) {
        $allIssues | ForEach-Object { Write-Log "ISSUE" $_.Message }
        if ($Action) { Invoke-Fix $allIssues $config }
    } else {
        Write-Log "OK" "系统健康"
    }
    return $allIssues.Count
}

function Start-WatchdogJob {
    param([int]$Interval = 60)
    
    $job = Get-ScheduledJob -Name $script:JobName -ErrorAction SilentlyContinue
    if ($job) {
        Write-Host "Job 已存在，运行中..."
        return
    }
    
    $jobScript = @"
`$config = Get-Content '$Config' | ConvertFrom-Json
`$issues = @()

`$procs = Get-Process | Where-Object { `$config.processWhitelist -contains `$_.Name }
foreach (`$proc in `$procs) {
    `$memMB = [math]::Round(`$proc.WorkingSet64 / 1MB, 2)
    if (`$memMB -gt `$config.maxMemoryMB) {
        Write-Host "[ISSUE] `$(`$proc.Name)(PID:`$($proc.Id)) 内存 `$memMB MB"
        if (`$config.autoKill) { Stop-Process -Id `$proc.Id -Force -ErrorAction SilentlyContinue }
    }
}

Write-Host "[OK] 检查完成"
"@

    Register-ScheduledJob -Name $script:JobName -ScriptBlock { 
        param($cfgPath)
        $config = Get-Content $cfgPath | ConvertFrom-Json
        Get-Process | Where-Object { $config.processWhitelist -contains $_.Name } | ForEach-Object {
            $memMB = [math]::Round($_.WorkingSet64 / 1MB, 2)
            if ($memMB -gt $config.maxMemoryMB) {
                Write-Host "[ISSUE] $($_.Name)(PID:$($_.Id)) 内存 ${memMB}MB"
                if ($config.autoKill) { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
            }
        }
    } -ArgumentList $Config -RunEvery (New-TimeSpan -Seconds $Interval) | Out-Null
    
    Write-Host "已启动后台轮询，每 ${Interval}秒检查一次"
}

function Stop-WatchdogJob {
    Unregister-ScheduledJob -Name $script:JobName -Force -ErrorAction SilentlyContinue
    Write-Host "已停止后台轮询"
}

function Get-WatchdogJobStatus {
    $job = Get-ScheduledJob -Name $script:JobName -ErrorAction SilentlyContinue
    if ($job) {
        Write-Host "Job: $($job.Name)"
        Write-Host "状态: $($job.State)"
        Write-Host "下次运行: $($job.NextRunTime)"
    } else {
        Write-Host "Job 未运行"
    }
}

# Main
if ($StartJob) { Start-WatchdogJob -Interval $IntervalSeconds }
elseif ($StopJob) { Stop-WatchdogJob }
elseif ($Status) { Get-WatchdogJobStatus }
else {
    $config = Load-Config $Config
    if ($Check) { Run-Check $config }
    elseif ($Action) { Run-Check $config -Action }
}