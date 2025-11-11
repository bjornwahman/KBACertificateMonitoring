param($SourceId, $ManagedEntityId, $TargetId)

$ErrorActionPreference = "Stop"

$api = New-Object -ComObject "MOM.ScriptAPI"
$discoveryData = $api.CreateDiscoveryData(0, $SourceId, $ManagedEntityId)

$configPath = "C:\ProgramData\Kungsbacka\CertificateWatchers.json"

try {
    if (-not (Test-Path -Path $configPath -PathType Leaf)) {
        throw "Konfigurationsfilen '$configPath' kunde inte hittas."
    }

    $json = Get-Content -Path $configPath -Raw -Encoding UTF8

    if ([string]::IsNullOrWhiteSpace($json)) {
        throw "Konfigurationsfilen '$configPath' är tom."
    }

    $entries = $json | ConvertFrom-Json

    foreach ($entry in @($entries)) {
        if (-not $entry.hostname) {
            $api.LogScriptEvent("Discover-KBACertificateWatchers", 4001, 2, "En post saknar 'hostname' och hoppar över.")
            continue
        }

        $hostname = [string]$entry.hostname

        $port = 443
        if ($entry.PSObject.Properties['port']) {
            $port = [int]$entry.port
        }

        $threshold = 30
        if ($entry.PSObject.Properties['thresholdDays']) {
            $threshold = [int]$entry.thresholdDays
        }
        $displayName = if ($entry.displayName) { [string]$entry.displayName } else { "$hostname certificate" }

        $instance = $discoveryData.CreateClassInstance("$MPElement[Name='CertLib!Kungsbacka.Certificate.CertificateWatcher']$")
        $instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
        $instance.AddProperty("$MPElement[Name='CertLib!Kungsbacka.Certificate.CertificateWatcher']/Hostname$", $hostname)
        $instance.AddProperty("$MPElement[Name='CertLib!Kungsbacka.Certificate.CertificateWatcher']/Port$", $port)
        $instance.AddProperty("$MPElement[Name='CertLib!Kungsbacka.Certificate.CertificateWatcher']/ThresholdDays$", $threshold)

        $discoveryData.AddInstance($instance)

        $relationship = $discoveryData.CreateRelationshipInstance("$MPElement[Name='CertLib!Kungsbacka.Certificate.CertificateWatcherHosts']$")
        $relationship.Source = $TargetId
        $relationship.Target = $instance
        $discoveryData.AddInstance($relationship)
    }
}
catch {
    $api.LogScriptEvent("Discover-KBACertificateWatchers", 4000, 1, "Misslyckades med att läsa '$configPath'. Fel: $($_.Exception.Message)")
}

$discoveryData
