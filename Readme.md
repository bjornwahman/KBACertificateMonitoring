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
- Discovery (`Kungsbacka.Certificate.rbokKungsbackaSe.CertificateWatcher.Discovery`) körs på samtliga management-servrar.
- Skapar en instans för `rbok.kungsbacka.se` och kopplar den till respektive server.

### Monitoring
- Monitor (`Kungsbacka.Certificate.rbokKungsbackaSe.CertificateExpiry.Monitor`) använder en PowerShell tvåtillståndsmonitor.
- Tröskelvärdet är 30 dagar innan utgång och kan ändras genom variabeln `$threshold` i skriptet.
- Skapar ett larm med texten från property-bagen när certifikatet närmar sig utgång eller inte kan läsas.

### Views
- State-vy (`Kungsbacka.Certificate.CertificateWatcher.StateView`) som visar status för det upptäckta certifikatet.

## Anpassning och utökning

Vill du lägga till fler certifikat i framtiden kan du:

1. Kopiera discovery-definitionen och ge den ett nytt, unikt ID (t.ex. `Kungsbacka.Certificate.<hostname>.CertificateWatcher.Discovery`) samt uppdatera `Hostname`- och `Port`-värdena.
2. Duplicera monitorn och byt ut ID:n inklusive alertmeddelandet (följ samma mönster som `...rbokKungsbackaSe...`) så att varje certifikat får en unik monitor- och strängidentitet.
3. Utöka vy-paketet med ytterligare vyer eller kolumner för de nya certifikaten.

Kom ihåg att uppdatera `LanguagePack`-sektionerna i respektive Management Pack med namn och beskrivningar för varje nytt objekt.
