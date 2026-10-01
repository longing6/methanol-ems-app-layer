<#
将 Simulink Agentic Toolkit 的三个技能组注册到 TRAE 技能目录。

用法:
  1. 按实际情况修改下面的 $ToolkitRoot 与 $SkillsTarget
  2. 以管理员身份运行 PowerShell（或先开启 Windows 开发者模式），然后执行:
       powershell -ExecutionPolicy Bypass -File .\setup-simulink-skills.ps1
  3. 若无法创建符号链接，改用复制模式:
       powershell -ExecutionPolicy Bypass -File .\setup-simulink-skills.ps1 -Copy

说明:
  只注册三组技能。官方明确提示:技能组装得越多，触发准确率越低。
#>

param(
    [switch]$Copy
)

# ==== 按需修改 ====
$ToolkitRoot  = "C:\REPLACE_WITH_PATH\simulink-agentic-toolkit"
$SkillsTarget = "$env:USERPROFILE\.trae-cn\skills"   # 全局技能目录；项目级可改为 <项目根>\.trae\skills
# ==================

$Groups = @(
    "model-based-design-core",
    "verification-validation-and-test",
    "code-generation"
)

if (-not (Test-Path $ToolkitRoot)) {
    Write-Error "找不到 toolkit 目录: $ToolkitRoot"
    exit 1
}

New-Item -ItemType Directory -Force -Path $SkillsTarget | Out-Null

foreach ($g in $Groups) {
    $src = Join-Path $ToolkitRoot "skills-catalog\$g"
    if (-not (Test-Path $src)) {
        Write-Warning "跳过（目录不存在）: $src"
        continue
    }
    Get-ChildItem -Directory $src | ForEach-Object {
        $link = Join-Path $SkillsTarget $_.Name
        if (Test-Path $link) {
            Write-Host "已存在，跳过: $($_.Name)"
            return
        }
        if ($Copy) {
            Copy-Item -Recurse -Force $_.FullName $link
            Write-Host "已复制: $($_.Name)"
        }
        else {
            try {
                New-Item -ItemType SymbolicLink -Path $link -Target $_.FullName -ErrorAction Stop | Out-Null
                Write-Host "已链接: $($_.Name)"
            }
            catch {
                Write-Warning "链接失败（需管理员权限或开发者模式）: $($_.Name) —— 可加 -Copy 改用复制模式"
            }
        }
    }
}

Write-Host ""
Write-Host "完成。请确认 TRAE 的技能目录与 $SkillsTarget 一致，否则技能不会被加载。"
