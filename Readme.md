# Kungsbacka Certificate Monitoring


Detta repo innehåller ett set oförseglade Management Pack för System Center Operations Manager (SCOM) som tillsammans övervakar SSL-certifikatet för `rbok.kungsbacka.se`.

## Struktur

| Mapp / fil | Beskrivning |
|------------|-------------|
| `managementpack/Kungsbacka.Certificate.Library.xml` | Grundläggande klass- och relationsdefinitioner som delas av övriga paket. |
| `managementpack/Kungsbacka.Certificate.Discovery.xml` | Discovery-paket som skapar certifikatsinstansen på management-servrarna. |
| `managementpack/Kungsbacka.Certificate.Monitoring.xml` | Monitor-paket med PowerShell-baserad tvåtillståndsmonitor och larmtext. |
| `managementpack/Kungsbacka.Certificate.Views.xml` | Presentationspaket som innehåller state-vy för certifikatsobjektet. |

## Översikt per Management Pack

### Library
- Definierar klassen `Kungsbacka.Certificate.CertificateWatcher` och relationen till management-servrar.
- Delas av discovery-, monitor- och vy-paketen genom referenser.

### Discovery
- Discovery (`Kungsbacka.Certificate.CertificateWatcher.Discovery`) körs på samtliga management-servrar.
- Skapar en instans för `rbok.kungsbacka.se` och kopplar den till respektive server.

### Monitoring
- Monitor (`Kungsbacka.Certificate.CertificateExpiry.Monitor`) använder en PowerShell tvåtillståndsmonitor.
- Tröskelvärdet är 30 dagar innan utgång och kan ändras genom variabeln `$threshold` i skriptet.
- Skapar ett larm med texten från property-bagen när certifikatet närmar sig utgång eller inte kan läsas.

### Views
- State-vy (`Kungsbacka.Certificate.CertificateWatcher.StateView`) som visar status för det upptäckta certifikatet.
=======
Detta repo innehåller ett oförseglat Management Pack för System Center Operations Manager (SCOM) som övervakar SSL-certifikatet för `rbok.kungsbacka.se`.

## Innehåll

| Mapp / fil | Beskrivning |
|------------|-------------|
| `managementpack/KBACertificateMonitoring.xml` | Själva management packet med discovery, monitor och vyer. |

## Funktioner i Management Packet

- **Discovery** (`Kungsbacka.CertificateMonitoring.CertificateWatcher.Discovery`)
  - Körs på samtliga management-servrar och skapar ett klassobjekt för målet `rbok.kungsbacka.se`.
- **Monitor** (`Kungsbacka.CertificateMonitoring.CertificateExpiry.Monitor`)
  - PowerShell-baserad tvåtillståndsmonitor som använder samma logik som skriptet i frågan för att kontrollera certifikatets utgångsdatum.
  - Standardgränsen är satt till 30 dagar men kan ändras genom att justera variabeln `$threshold` i skriptet.
- **Vy** (`Kungsbacka.CertificateMonitoring.CertificateWatcher.StateView`)
  - En enkel state-vy som visar hälsotillståndet för det upptäckta certifikatet.


## Anpassning och utökning

Vill du lägga till fler certifikat i framtiden kan du:


1. Skapa en ny discovery i discovery-paketet med uppdaterade `Hostname` och `Port`-värden.
2. Kopiera monitorn i monitoring-paketet, uppdatera ID:n och hårdkodade värden samt lägg till relevanta språksträngar.
3. Utöka vy-paketet med ytterligare vyer eller kolumner för de nya certifikaten.

Kom ihåg att uppdatera `LanguagePack`-sektionerna i respektive Management Pack med namn och beskrivningar för varje nytt objekt.
=======
1. Kopiera discovery-sektionen och uppdatera `Hostname` och `Port` för det nya certifikatet.
2. Duplicera motsvarande monitor-block och uppdatera ID:n, display-strängar samt hårdkodade värden.
3. Lägg till en ny vy (eller uppdatera befintlig) för att visa det nya certifikatet.

Kom ihåg att uppdatera `LanguagePack`-sektionen med rätt namn och beskrivningar för varje nytt objekt.
