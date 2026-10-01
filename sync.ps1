# 把源文件同步到发布目录
#
# 为什么要这一步：
#   根目录的 .html      = 你改代码的地方（源文件）
#   deploy/index.html   = Netlify 真正发布的文件
# 两者必须一致。忘了同步就会出现「本地看着改了，线上还是旧的」。
#
# 用法：改完源文件后，在仓库根目录执行
#   powershell -ExecutionPolicy Bypass -File .\sync.ps1
#   或
#   pwsh -File .\sync.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# 不硬编码中文文件名 —— 直接找出根目录下唯一那个 .html
$srcItem = Get-ChildItem -Path $root -Filter '*.html' -File | Select-Object -First 1
if (-not $srcItem) {
    Write-Host "[x] No source .html found in $root" -ForegroundColor Red
    exit 1
}

$dst = Join-Path $root 'deploy\index.html'
if (-not (Test-Path (Split-Path -Parent $dst))) {
    Write-Host "[x] deploy\ folder not found" -ForegroundColor Red
    exit 1
}

Copy-Item $srcItem.FullName $dst -Force

$a = (Get-FileHash $srcItem.FullName -Algorithm SHA256).Hash
$b = (Get-FileHash $dst -Algorithm SHA256).Hash
if ($a -eq $b) {
    Write-Host "[OK] Synced: $($srcItem.Name)  ->  deploy\index.html" -ForegroundColor Green
    Write-Host "     SHA256 $($a.Substring(0,16))...  match" -ForegroundColor DarkGray
} else {
    Write-Host "[x] Hash mismatch after copy" -ForegroundColor Red
    exit 1
}
