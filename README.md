# Winget 批量安装脚本

这个 PowerShell 脚本提供了一种简单高效的方式来批量安装常用软件，使用 Windows 包管理器 (Winget) 自动化安装过程。

## 功能特点

- **一键安装**：自动安装 16 款常用开发工具和实用软件
- **智能检测**：自动检查管理员权限和 Winget 环境
- **实时进度**：动态显示安装进度和状态
- **详细报告**：提供安装摘要和错误诊断信息
- **彩色输出**：直观的彩色控制台界面，状态一目了然

## 包含软件

| 软件名称 | ID |
|----------|----|
| Clash Verge Rev | `ClashVergeRev.ClashVergeRev` |
| 钉钉 | `Alibaba.DingTalk` |
| VS Code | `Microsoft.VisualStudioCode` |
| 7-Zip | `7zip.7zip` |
| WizTree | `AntibodySoftware.WizTree` |
| Sublime Text 4 | `SublimeHQ.SublimeText.4` |
| DB Browser for SQLite | `DBBrowserForSQLite.DBBrowserForSQLite` |
| GitHub Desktop | `GitHub.GitHubDesktop` |
| Google Chrome | `Google.Chrome.EXE` |
| FFmpeg | `Gyan.FFmpeg` |
| Oh My Posh | `JanDeDobbeleer.OhMyPosh` |
| PowerShell | `Microsoft.PowerShell` |
| PowerToys | `Microsoft.PowerToys` |
| Visual Studio 2022 | `Microsoft.VisualStudio.2022.Community` |
| Python 3.10 | `Python.Python.3.10` |
| Everything | `voidtools.Everything` |

## 系统要求

- Windows 10 1709 或更高版本
- Windows 11
- PowerShell 5.1 或更高版本
- 已安装 Winget（脚本会自动检测）

## 使用方法

1. **保存脚本**：
   - 将脚本保存为 `.ps1` 文件（如 `install-apps.ps1`）

2. **执行脚本**：
   ```powershell
   # 方法1：右键选择"以管理员身份运行"
   # 方法2：在管理员权限的PowerShell中运行：
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\install-apps.ps1
   ```

3. **等待安装完成**：
   - 脚本会自动执行所有安装步骤
   - 安装过程会有实时进度显示
   - 安装完成后会显示详细报告

## 自定义软件列表

要修改安装的软件列表，编辑脚本中的 `$packages` 数组部分：

```powershell
$packages = @(
    @{Id = "Package.Id"; Name = "软件名称"},
    @{Id = "Another.Package"; Name = "另一个软件"},
    # 添加或删除此行以修改软件列表
)
```

## 常见问题解决

### 1. Winget 未安装错误

如果提示 `Winget未安装`，请：
1. 打开 Microsoft Store
2. 搜索 "应用安装程序"
3. 点击更新或安装

### 2. 管理员权限问题

如果脚本未以管理员身份运行：
- 关闭当前 PowerShell 窗口
- 右键点击脚本文件
- 选择"以管理员身份运行"

### 3. 个别软件安装失败

当某个软件安装失败时：
1. 检查错误信息中的具体原因
2. 尝试手动安装：
   ```powershell
   winget install --id <软件ID> --source winget
   ```
3. 常见解决方案：
   - 确保网络连接正常
   - 关闭杀毒软件临时重试
   - 检查磁盘空间（特别是Visual Studio需要20GB+空间）

### 4. 脚本执行策略限制

如果遇到执行策略错误：
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

## 贡献与反馈

欢迎提交问题和改进建议：
- [提交 Issue](https://github.com/xlzhen-940218/WindowsSoftwareAutoInstall/issues)
- [Fork 并提交 PR](https://github.com/xlzhen-940218/WindowsSoftwareAutoInstall/fork)

## 许可证

本项目采用 [MIT 许可证](LICENSE)

---

**提示**：Visual Studio 2022 安装可能需要较长时间（30分钟以上），请确保设备在安装过程中保持通电和网络连接。
