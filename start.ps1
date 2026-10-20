# CB Lens local launcher (Windows PowerShell)
# Usage: powershell -ExecutionPolicy Bypass -File .\start.ps1
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
try { chcp 65001 | Out-Null } catch {}

$DataDir = if ($env:CB_DATA_DIR) { $env:CB_DATA_DIR } else { Join-Path $env:LOCALAPPDATA "CBLens\data" }
$LogDir = Join-Path $DataDir "logs"
New-Item -ItemType Directory -Force -Path $DataDir, $LogDir | Out-Null
$env:CB_DATA_DIR = $DataDir
$env:CB_LOG_DIR = $LogDir
$env:PYTHONPATH = Join-Path $Root "backend"
$env:CB_HOST = if ($env:CB_HOST) { $env:CB_HOST } else { "127.0.0.1" }
$env:CB_PORT = if ($env:CB_PORT) { $env:CB_PORT } else { "8765" }

$Python = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $Python) {
    Write-Host "未找到 Python。请先安装 Python 3.11+（建议 3.12）并加入 PATH。" -ForegroundColor Red
    Read-Host "按 Enter 退出"
    exit 1
}

function Test-PythonDeps {
    & $Python.Source -c "import flask, httpx, pandas, numpy" 2>$null
    return ($LASTEXITCODE -eq 0)
}

if (-not (Test-PythonDeps)) {
    Write-Host "正在安装 Python 依赖…" -ForegroundColor Cyan
    & $Python.Source -m pip install -r (Join-Path $Root "backend\requirements.txt")
    if ($LASTEXITCODE -ne 0) {
        Write-Host "依赖安装失败。请手动运行：python -m pip install -r backend\requirements.txt" -ForegroundColor Red
        Read-Host "按 Enter 退出"
        exit 1
    }
}

$DistIndex = Join-Path $Root "frontend\dist\index.html"
if (-not (Test-Path $DistIndex)) {
    $Npm = (Get-Command npm -ErrorAction SilentlyContinue)
    if (-not $Npm) {
        Write-Host "前端尚未构建，且未找到 npm。请安装 Node.js 20+ 后运行 build.ps1。" -ForegroundColor Red
        Read-Host "按 Enter 退出"
        exit 1
    }
    Write-Host "首次运行：正在构建前端（约 10–30 秒）…" -ForegroundColor Cyan
    Push-Location (Join-Path $Root "frontend")
    try {
        if (-not (Test-Path "node_modules")) {
            & $Npm.Source install --no-audit --no-fund --ignore-scripts
            if ($LASTEXITCODE -ne 0) {
                & $Npm.Source install --no-audit --no-fund
            }
        }
        & $Npm.Source run build
        if ($LASTEXITCODE -ne 0) { throw "前端构建失败" }
    } finally {
        Pop-Location
    }
}

$Url = "http://$($env:CB_HOST):$($env:CB_PORT)"
Write-Host ""
Write-Host "  CB Lens / 转债透镜" -ForegroundColor Cyan
Write-Host "  本地地址: $Url" -ForegroundColor White
Write-Host "  数据目录: $DataDir" -ForegroundColor DarkGray
Write-Host "  首次启动会在后台回填约 300 只转债的历史 K 线，请稍候。" -ForegroundColor DarkGray
Write-Host "  按 Ctrl+C 停止。" -ForegroundColor DarkGray
Write-Host ""

if ($env:CB_NO_BROWSER -ne "1") {
    Start-Job -ScriptBlock {
        param($u)
        Start-Sleep -Seconds 3
        Start-Process $u
    } -ArgumentList $Url | Out-Null
}

& $Python.Source -m app.server
