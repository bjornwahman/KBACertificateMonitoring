# Kungsbacka Certificate Monitoring

Detta repo innehåller ett set oförseglade Management Pack för System Center Operations Manager (SCOM) som tillsammans övervakar SSL-certifikaten för `rbok.kungsbacka.se` och `passbolt.kba.local`.

## Struktur

| Mapp / fil | Beskrivning |
|------------|-------------|
| `managementpack/Kungsbacka.Certificate.Library.xml` | Grundläggande klass- och relationsdefinitioner som delas av övriga paket. |
| `managementpack/Kungsbacka.Certificate.Discovery.xml` | Discovery-paket som läser JSON-konfigurationen och skapar certifikatsinstanserna på management-servrarna. |
| `managementpack/monitoring/Kungsbacka.Certificate.CertificateExpiry.Monitoring.xml` | Monitor-paket med PowerShell-baserad tvåtillståndsmonitor som använder samma JSON-konfiguration. |
| `managementpack/Kungsbacka.Certificate.Views.xml` | Presentationspaket som innehåller state-vy för certifikatsobjekten. |
| `managementpack/scripts/*.ps1` | Självständiga PowerShell-skript som bäddas in i respektive Management Pack. |
| `managementpack/CertificateWatchers.json` | Exempelfil med de certifikat som ska övervakas. Kopieras till management-servrarna. |

## Översikt per Management Pack

### Library
- Definierar den värdbara klassen `Kungsbacka.Certificate.CertificateWatcher` med egenskaperna `Hostname`, `Port` och `ThresholdDays`.
- Innehåller även relationen mellan management-servrar och certifikatsobjekten.
- Delas av discovery-, monitor- och vy-paketen genom referenser.

### Discovery
- `Kungsbacka.Certificate.CertificateWatcher.Discovery` körs på samtliga management-servrar en gång per dygn.
- Läser `CertificateWatchers.json`, skapar instanser av klassen och kopplar dem till respektive server.
- Bäddar in skriptet `Discover-KBACertificateWatchers.ps1` från `managementpack/scripts/`.

### Monitoring
- `Kungsbacka.Certificate.CertificateExpiry.Monitoring` ligger i en egen fil för att varje framtida monitor ska kunna versioneras separat.
- Monitorn `Kungsbacka.Certificate.CertificateExpiry.Monitor` använder en PowerShell tvåtillståndsmonitor riktad mot certifikatklassen.
- Läser `CertificateWatchers.json` för att hämta tröskelvärde (dagar kvar) per certifikat och faller tillbaka till värdet på instansen (standard 30 dagar).
- Skapar ett larm med texten från property-bagen när certifikatet närmar sig utgång eller inte kan läsas.
- Bäddar in skriptet `Test-KBACertificateLifetime.ps1` från `managementpack/scripts/`.

### Views
- State-vy (`Kungsbacka.Certificate.CertificateWatcher.StateView`) som visar status för de upptäckta certifikaten.

## Anpassning och utökning

1. Skapa katalogen `C:\ProgramData\Kungsbacka` om den saknas och kopiera `managementpack/CertificateWatchers.json` till `C:\ProgramData\Kungsbacka\CertificateWatchers.json` på samtliga management-servrar.
2. Lägg till fler objekt i JSON-filen med fälten `displayName`, `hostname`, `port` och (valfritt) `thresholdDays` för varje nytt certifikat.
3. Importera eller uppdatera Management Packen i SCOM. Discovery och monitor använder samma konfiguration så inga ytterligare ändringar i XML-filerna krävs.

Behöver du anpassa larmtexter eller vyer kan du uppdatera språksträngarna i respektive Management Pack, men själva logiken hämtar alla inställningar från JSON-filen.
