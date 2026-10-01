# ============================================================
#  把二维码嵌进游戏
#
#  用法：
#    powershell -ExecutionPolicy Bypass -File .\set-qr.ps1 -ImagePath "D:\我的二维码.png"
#    powershell -ExecutionPolicy Bypass -File .\set-qr.ps1 -Clear      # 清除二维码
#
#  它会：
#    1. 把图片转成 base64 内嵌进源码的 PROMO.qr
#    2. 自动同步到 deploy/index.html
#    3. 校验结果
#
#  为什么用 base64 而不是放个 qr.png：
#    游戏是单文件设计。二维码单独放一个文件的话，
#    一旦忘了上传，玩家战报图上的二维码就会变成"加载失败"——
#    而分享出去的战报图是收不回来的。内嵌就不会有这个问题。
# ============================================================

param(
    [string]$ImagePath,
    [switch]$Clear
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src  = Get-ChildItem -Path $root -Filter '*.html' -File | Select-Object -First 1
if (-not $src) { Write-Host '[x] 根目录找不到 .html 源文件' -ForegroundColor Red; exit 1 }
$html = $src.FullName

Write-Host ''
Write-Host '=== 二维码配置工具 ===' -ForegroundColor Cyan
Write-Host "源文件: $($src.Name)"
Write-Host ''

$text = [System.IO.File]::ReadAllText($html, [System.Text.Encoding]::UTF8)
if ($text -notmatch "qr:'") { Write-Host '[x] 源码里找不到 PROMO.qr 配置项' -ForegroundColor Red; exit 1 }

if ($Clear) {
    $text = [regex]::Replace($text, "qr:'[^']*'", "qr:''", 1)
    [System.IO.File]::WriteAllText($html, $text, (New-Object System.Text.UTF8Encoding $false))
    Write-Host '[OK] 已清除二维码' -ForegroundColor Green
} else {
    if (-not $ImagePath) { Write-Host '[x] 请用 -ImagePath 指定二维码图片，或用 -Clear 清除' -ForegroundColor Red; exit 1 }
    if (-not (Test-Path $ImagePath)) { Write-Host "[x] 找不到文件: $ImagePath" -ForegroundColor Red; exit 1 }

    $img  = Get-Item $ImagePath
    $ext  = $img.Extension.ToLower()
    $mime = switch ($ext) {
        '.png'  { 'image/png' }
        '.jpg'  { 'image/jpeg' }
        '.jpeg' { 'image/jpeg' }
        '.gif'  { 'image/gif' }
        '.webp' { 'image/webp' }
        default { Write-Host "[x] 不支持的格式: $ext（请用 png / jpg）" -ForegroundColor Red; exit 1 }
    }

    $bytes  = [System.IO.File]::ReadAllBytes($img.FullName)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $dataUri = "data:$mime;base64,$base64"

    Write-Host ("[1/3] 读取图片   {0}  {1:N1} KB" -f $img.Name, ($img.Length/1KB)) -ForegroundColor Green

    $before = $text.Length
    $text = [regex]::Replace($text, "qr:'[^']*'", { param($m) "qr:'$dataUri'" }, 1)
    [System.IO.File]::WriteAllText($html, $text, (New-Object System.Text.UTF8Encoding $false))
    $after = (Get-Item $html).Length
    Write-Host ("[2/3] 已内嵌     源码 {0:N1} KB → {1:N1} KB" -f ($before/1KB), ($after/1KB)) -ForegroundColor Green
}

# 同步到发布目录
$dst = Join-Path $root 'deploy\index.html'
if (Test-Path (Split-Path -Parent $dst)) {
    Copy-Item $html $dst -Force
    Write-Host '[3/3] 已同步到 deploy\index.html' -ForegroundColor Green
} else {
    Write-Host '[3/3] 没找到 deploy\ 目录，跳过同步' -ForegroundColor Yellow
}

# 校验
$check = [System.IO.File]::ReadAllText($html, [System.Text.Encoding]::UTF8)
$m = [regex]::Match($check, "qr:'([^']*)'")
if ($m.Success) {
    $v = $m.Groups[1].Value
    if ($v -eq '') {
        Write-Host ''
        Write-Host '当前状态：未配置二维码（战报图会显示虚线占位框）' -ForegroundColor Yellow
    } else {
        Write-Host ''
        Write-Host ("当前状态：已配置  长度 {0:N0} 字符  前缀 {1}..." -f $v.Length, $v.Substring(0, [Math]::Min(30, $v.Length))) -ForegroundColor Green
    }
}

Write-Host ''
Write-Host '下一步：' -ForegroundColor White
Write-Host '  1. 本地双击打开 index.html，玩到结算页，点「生成战报图」看看效果'
Write-Host '  2. 确认二维码清晰可扫（手机扫一下试试）'
Write-Host '  3. 上传更新：git add . ; git commit -m "配置二维码" ; git push'
Write-Host ''
