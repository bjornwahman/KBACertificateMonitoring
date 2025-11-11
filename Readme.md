# Kungsbacka Certificate Monitoring

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

1. Kopiera discovery-sektionen och uppdatera `Hostname` och `Port` för det nya certifikatet.
2. Duplicera motsvarande monitor-block och uppdatera ID:n, display-strängar samt hårdkodade värden.
3. Lägg till en ny vy (eller uppdatera befintlig) för att visa det nya certifikatet.

Kom ihåg att uppdatera `LanguagePack`-sektionen med rätt namn och beskrivningar för varje nytt objekt.
