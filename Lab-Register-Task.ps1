# Policy (low-risk .vbs) + Task Scheduler: moi lan dang nhap -> ap lai.
# Chi may lab khi giao vien cho phep. Double-click Lab-Register-Task.lnk

param([switch]$ScheduledLogon)

$ErrorActionPreference = 'Stop'

function Apply-LabPolicy {
    $p = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Associations'
    if (-not (Test-Path -LiteralPath $p)) {
        New-Item -Path $p -Force | Out-Null
    }
    $prop = Get-ItemProperty -Path $p -Name LowRiskFileTypes -ErrorAction SilentlyContinue
    if ($null -ne $prop) {
        Set-ItemProperty -LiteralPath $p -Name 'LowRiskFileTypes' -Value '.vbs;.vbe'
    } else {
        New-ItemProperty -LiteralPath $p -Name 'LowRiskFileTypes' -Value '.vbs;.vbe' -PropertyType String -Force | Out-Null
    }
}

if ($ScheduledLogon) {
    Apply-LabPolicy
    exit 0
}

Apply-LabPolicy

$taskName = 'ITProtect-Lab-EnableVBS'
$self = (Resolve-Path -LiteralPath $PSCommandPath).Path
$taskArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$self`" -ScheduledLogon"
$action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument $taskArgs
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

try { Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue } catch {}

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Write-Host "Da ap dung policy va tao task: $taskName"
Write-Host "Dang xuat / dang nhap lai de kiem tra."
