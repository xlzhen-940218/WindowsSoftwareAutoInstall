Write-Host "软件批量安装脚本 - 开始执行" -ForegroundColor Cyan
Write-Host "========================================"

# 检查管理员权限
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "错误: 请以管理员身份运行此脚本!" -ForegroundColor Red
    Write-Host "正在尝试重新以管理员身份运行..."
    Start-Sleep -Seconds 2
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 检查winget可用性
try {
    $wingetVersion = winget --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Winget未安装"
    }
    Write-Host "检测到Winget版本: $wingetVersion" -ForegroundColor Green
}
catch {
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "请确保已安装Windows应用商店或Winget:"
    Write-Host "1. 打开Microsoft Store"
    Write-Host "2. 搜索 '应用安装程序'"
    Write-Host "3. 点击更新或安装"
    exit 1
}

# 软件包列表
$packages = @(
    @{Id = "ClashVergeRev.ClashVergeRev";      Name = "Clash Verge Rev"},
    @{Id = "Alibaba.DingTalk";                 Name = "钉钉"},
    @{Id = "Microsoft.VisualStudioCode";       Name = "VS Code"},
    @{Id = "7zip.7zip";                        Name = "7-Zip"},
    @{Id = "AntibodySoftware.WizTree";         Name = "WizTree"},
    @{Id = "SublimeHQ.SublimeText.4";          Name = "Sublime Text 4"},
    @{Id = "DBBrowserForSQLite.DBBrowserForSQLite"; Name = "DB Browser for SQLite"},
    @{Id = "GitHub.GitHubDesktop";             Name = "GitHub Desktop"},
    @{Id = "Google.Chrome.EXE";                Name = "Google Chrome"},
    @{Id = "Gyan.FFmpeg";                      Name = "FFmpeg"},
    @{Id = "JanDeDobbeleer.OhMyPosh";          Name = "Oh My Posh"},
    @{Id = "Microsoft.PowerShell";             Name = "PowerShell"},
    @{Id = "Microsoft.PowerToys";              Name = "PowerToys"},
    @{Id = "Microsoft.VisualStudio.2022.Community"; Name = "Visual Studio 2022"},
    @{Id = "Python.Python.3.10";               Name = "Python 3.10"},
    @{Id = "voidtools.Everything";             Name = "Everything"},
    @{Id = "VideoLAN.VLC"                      Name = "VLC media player"}
    @{Id = "Geeks3D.FurMark.2"                 Name = "Geeks3D FurMark 2"}
    @{Id = "Eassos.DiskGenius"                 Name = "DiskGenius"}
    @{Id = "Apple.iTunes"                      Name = "iTunes"}
    @{Id = "MSYS2.MSYS2"                       Name = "MSYS2"}
    @{Id = "OBSProject.OBSStudio"              Name = "OBSStudio"}
    @{Id = "Valve.Steam"                       Name = "Steam"}
    @{Id = "TigerVNC.TigerVNC"                 Name = "TigerVNC"}
    @{Id = "AntibodySoftware.WizTree"          Name = "WizTree"}
)

# 安装函数（显示详细输出）
function Install-Package {
    param($id, $name)
    
    Write-Host "`n[开始安装] $name ($id)" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor DarkYellow
    
    # 创建临时文件记录输出
    $tempFile = [System.IO.Path]::GetTempFileName()
    
    try {
        # 执行安装并捕获所有输出
        $process = Start-Process -FilePath "winget" `
            -ArgumentList "install --id $id --source winget --accept-package-agreements --accept-source-agreements" `
            -NoNewWindow `
            -PassThru `
            -RedirectStandardOutput $tempFile `
            -RedirectStandardError "$tempFile.errors"
        
        # 实时显示进度
        $dots = 0
        while (-not $process.HasExited) {
            $dots = ($dots + 1) % 4
            $progress = "." * $dots + " " * (3 - $dots)
            Write-Host "`r安装中$progress" -NoNewline -ForegroundColor Cyan
            Start-Sleep -Milliseconds 300
        }
        
        # 获取完整输出
        $output = Get-Content $tempFile -Raw -ErrorAction SilentlyContinue
        $errorOutput = Get-Content "$tempFile.errors" -Raw -ErrorAction SilentlyContinue
        
        # 检查结果
        if ($process.ExitCode -eq 0) {
            Write-Host "`r[安装成功] $name" -ForegroundColor Green
            Write-Host "----------------------------------------" -ForegroundColor DarkGreen
            return $true
        }
        else {
            Write-Host "`r[安装失败] $name (错误代码: $($process.ExitCode))" -ForegroundColor Red
            Write-Host "----------------------------------------" -ForegroundColor DarkRed
            
            # 显示错误摘要
            if ($errorOutput) {
                Write-Host "错误信息:" -ForegroundColor Red
                $errorOutput -split "`n" | Select-Object -Last 10 | ForEach-Object {
                    Write-Host "  $_" -ForegroundColor Red
                }
            }
            elseif ($output) {
                $lastLines = $output -split "`n" | Select-Object -Last 5
                Write-Host "最后输出:" -ForegroundColor Yellow
                $lastLines | ForEach-Object {
                    Write-Host "  $_" -ForegroundColor Yellow
                }
            }
            
            Write-Host "----------------------------------------" -ForegroundColor DarkRed
            return $false
        }
    }
    catch {
        Write-Host "`r[执行错误] $name" -ForegroundColor Red
        Write-Host "错误详情: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    finally {
        # 清理临时文件
        Remove-Item $tempFile -ErrorAction SilentlyContinue
        Remove-Item "$tempFile.errors" -ErrorAction SilentlyContinue
    }
}

# 主安装流程
$successCount = 0
$failedPackages = @()

Write-Host "`n开始批量安装软件 (共 $($packages.Count) 个)..." -ForegroundColor Cyan
$startTime = Get-Date

foreach ($pkg in $packages) {
    if (Install-Package -id $pkg.Id -name $pkg.Name) {
        $successCount++
    }
    else {
        $failedPackages += @{
            Name = $pkg.Name
            Id = $pkg.Id
        }
    }
}

# 计算总耗时
$endTime = Get-Date
$totalTime = $endTime - $startTime
$minutes = $totalTime.Minutes
$seconds = $totalTime.Seconds

# 输出摘要
Write-Host "`n安装摘要:" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host "开始时间: $($startTime.ToString('HH:mm:ss'))"
Write-Host "结束时间: $($endTime.ToString('HH:mm:ss'))"
Write-Host "总耗时  : ${minutes}分${seconds}秒"
Write-Host "----------------------------------------"
Write-Host "成功安装: $successCount/$($packages.Count)" -ForegroundColor Green

if ($failedPackages.Count -gt 0) {
    Write-Host "失败安装: $($failedPackages.Count)" -ForegroundColor Red
    Write-Host "失败软件列表:"
    $failedPackages | ForEach-Object {
        Write-Host "  - $($_.Name) ($($_.Id))" -ForegroundColor Red
    }
    
    Write-Host "`n重新安装建议:"
    Write-Host "1. 检查网络连接"
    Write-Host "2. 手动尝试安装: winget install --id <软件ID>"
    Write-Host "3. 查看错误信息确定具体原因"
}

if ($failedPackages.Count -eq 0) {
    Write-Host "`n所有软件已成功安装！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}
else {
    Write-Host "`n部分软件安装失败，请查看上方错误信息" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
}

# 完成提示
Write-Host "`n脚本执行完成，按任意键退出..." -ForegroundColor Cyan
[Console]::ReadKey($true) | Out-Null
