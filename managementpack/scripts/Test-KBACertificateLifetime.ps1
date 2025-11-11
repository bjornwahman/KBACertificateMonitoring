param($hostname, $port, $thresholdFromInstance)

$ErrorActionPreference = "Stop"

$hostname = [string]$hostname
$port = [int]$port

$ScomAPI = New-Object -ComObject "MOM.ScriptAPI"
$PropertyBag = $ScomAPI.CreatePropertyBag()

$configPath = "C:\ProgramData\Kungsbacka\CertificateWatchers.json"
$threshold = 30

if ($thresholdFromInstance -and ($thresholdFromInstance -as [int])) {
    $threshold = [int]$thresholdFromInstance
}

try {
    if (-not (Test-Path -Path $configPath -PathType Leaf)) {
        throw "Konfigurationsfilen '$configPath' hittades inte."
    }

    $json = Get-Content -Path $configPath -Raw -Encoding UTF8

    if (-not [string]::IsNullOrWhiteSpace($json)) {
        $entries = $json | ConvertFrom-Json
        $matching = @($entries) | Where-Object {
            ($_.hostname) -and ([string]$_.hostname).ToLowerInvariant() -eq $hostname.ToLowerInvariant() -and ([int]$_.port) -eq $port
        }

        if ($matching.Count -gt 0 -and $matching[0].PSObject.Properties['thresholdDays']) {
            $threshold = [int]$matching[0].thresholdDays
        }
    }
}
catch {
    $ScomAPI.LogScriptEvent("Test-KBACertificateLifetime", 4000, 2, "Använder tröskelvärdet $threshold dagar för $hostname:$port på grund av fel: $($_.Exception.Message)")
}

$tcpClient = $null
$sslStream = $null

try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient($hostname, $port)
    $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, { $true })
    $sslStream.AuthenticateAsClient($hostname)

    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $sslStream.RemoteCertificate
    $daysRemaining = [math]::Floor(($cert.NotAfter - (Get-Date)).TotalDays)

    if ($daysRemaining -le $threshold) {
        $state = "OverThreshold"
    }
    else {
        $state = "UnderThreshold"
    }

    $PropertyBag.AddValue("State", $state)
    $PropertyBag.AddValue("Hostname", $hostname)
    $PropertyBag.AddValue("DaysRemaining", $daysRemaining)
    $PropertyBag.AddValue("NotAfter", $cert.NotAfter.ToString("O"))
    $PropertyBag.AddValue("MessageText", "Certifikat för $hostname går ut $($cert.NotAfter) (Dagar kvar: $daysRemaining)")
}
catch {
    $PropertyBag.AddValue("State", "OverThreshold")
    $PropertyBag.AddValue("Hostname", $hostname)
    $PropertyBag.AddValue("DaysRemaining", -1)
    $PropertyBag.AddValue("NotAfter", "")
    $PropertyBag.AddValue("MessageText", "Kunde inte läsa certifikat för $hostname. Fel: $($_.Exception.Message)")
}
finally {
    if ($sslStream) { $sslStream.Dispose() }
    if ($tcpClient) { $tcpClient.Dispose() }
}

$PropertyBag
