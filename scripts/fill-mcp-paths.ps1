<#
将 .trae/mcp.json 中的占位符替换为本机真实路径，并校验 JSON 合法性。

用法（在项目根目录执行，只有 -ToolkitRoot 是必填）：

  powershell -ExecutionPolicy Bypass -File .\scripts\fill-mcp-paths.ps1 `
      -ToolkitRoot "D:\work\simulink-agentic-toolkit"

参数：
  -ToolkitRoot  simulink-agentic-toolkit 在本机的目录（必填）
  -ProjectRoot  本项目在本机的目录，默认取本脚本所在目录的上一级
  -GitRepoRoot  本地 git 仓库路径，默认同 -ProjectRoot
  -MatlabRoot   MATLAB 安装目录，默认 C:\Program Files\MATLAB\R2026a
  -DryRun       只打印结果，不写文件

说明：
  本脚本不做字符串替换，而是直接按 JSON 结构重建 args 数组，
  因此不存在「占位符替换不完整」或转义错误的风险。
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ToolkitRoot,
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$GitRepoRoot = "",
    [string]$MatlabRoot  = "C:\Program Files\MATLAB\R2026a",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($GitRepoRoot)) { $GitRepoRoot = $ProjectRoot }

$mcpFile = Join-Path $ProjectRoot ".trae\mcp.json"
if (-not (Test-Path $mcpFile)) { throw "找不到配置文件: $mcpFile" }

$extFile = Join-Path $ToolkitRoot "tools\tools.json"
if (-not (Test-Path $extFile)) { throw "找不到 Simulink 扩展工具文件: $extFile" }

$bin = Join-Path $env:USERPROFILE ".matlab\agentic-toolkits\bin\matlab-mcp-server.exe"
if (-not (Test-Path $bin)) {
    Write-Warning "MCP 二进制尚未安装: $bin"
    Write-Warning '请先在 MATLAB 中执行 setupAgenticToolkit("install") 后再启用该 server。'
}

$cfg = Get-Content -Raw -Encoding UTF8 $mcpFile | ConvertFrom-Json

$cfg.mcpServers.matlab.command = $bin
$cfg.mcpServers.matlab.args = @(
    "--matlab-root=$MatlabRoot",
    "--matlab-session-mode=existing",
    "--initial-working-folder=$ProjectRoot",
    "--extension-file=$extFile",
    "--disable-telemetry=true",
    "--log-level=info"
)
$cfg.mcpServers.git.args = @("mcp-server-git", "--repository", $GitRepoRoot)

$json = $cfg | ConvertTo-Json -Depth 10

if ($DryRun) {
    Write-Host $json
    return
}

# 以无 BOM 的 UTF-8 写入，避免部分 JSON 解析器被 BOM 干扰
[System.IO.File]::WriteAllText($mcpFile, $json, (New-Object System.Text.UTF8Encoding $false))
Write-Host "已写入: $mcpFile"

$remain = Select-String -Path $mcpFile -Pattern 'REPLACE_WITH_' -SimpleMatch
if ($remain) {
    Write-Warning "仍存在未替换的占位符:"
    $remain | ForEach-Object { Write-Warning $_.Line.Trim() }
    exit 1
}

Write-Host "校验通过: 无残留占位符，JSON 合法。"
