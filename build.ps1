$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $Root "frontend")
if (-not (Test-Path "node_modules")) {
    npm install --no-audit --no-fund --ignore-scripts
    if ($LASTEXITCODE -ne 0) { npm install --no-audit --no-fund }
}
npm run build
if ($LASTEXITCODE -ne 0) { throw "前端构建失败" }
Write-Host "构建完成：frontend\dist" -ForegroundColor Green
