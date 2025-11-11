# Kungsbacka Certificate Monitoring

Detta repo innehåller ett set oförseglade Management Pack för System Center Operations Manager (SCOM) som tillsammans övervakar SSL-certifikaten för `rbok.kungsbacka.se` och `passbolt.kba.local`.

## Struktur

| Mapp / fil | Beskrivning |
|------------|-------------|
| `managementpack/Kungsbacka.Certificate.Library.xml` | Grundläggande klass- och relationsdefinitioner som delas av övriga paket. |
| `managementpack/Kungsbacka.Certificate.Discovery.xml` | Discovery-paket som skapar certifikatsinstansen på management-servrarna. |
| `managementpack/Kungsbacka.Certificate.Monitoring.xml` | Monitor-paket med PowerShell-baserad tvåtillståndsmonitor och larmtext. |
| `managementpack/Kungsbacka.Certificate.Views.xml` | Presentationspaket som innehåller state-vy för certifikatsobjekten. |

## Översikt per Management Pack

### Library
- Definierar klassen `Kungsbacka.Certificate.CertificateWatcher` och relationen till management-servrar.
- Delas av discovery-, monitor- och vy-paketen genom referenser.

### Discovery
- Discoveries (`Kungsbacka.Certificate.rbokKungsbackaSe.CertificateWatcher.Discovery` och `Kungsbacka.Certificate.passboltKbaLocal.CertificateWatcher.Discovery`) körs på samtliga management-servrar.
- Skapar instanser för `rbok.kungsbacka.se` respektive `passbolt.kba.local` och kopplar dem till respektive server.

### Monitoring
- Monitorerna (`Kungsbacka.Certificate.rbokKungsbackaSe.CertificateExpiry.Monitor` och `Kungsbacka.Certificate.passboltKbaLocal.CertificateExpiry.Monitor`) använder en PowerShell tvåtillståndsmonitor.
- Tröskelvärdet är 30 dagar innan utgång och kan ändras genom variabeln `$threshold` i respektive skript.
- Varje monitor skapar ett larm med texten från property-bagen när certifikatet närmar sig utgång eller inte kan läsas.

### Views
- State-vy (`Kungsbacka.Certificate.CertificateWatcher.StateView`) som visar status för de upptäckta certifikaten.

## Anpassning och utökning

Vill du lägga till fler certifikat i framtiden kan du:

1. Kopiera discovery-definitionen och ge den ett nytt, unikt ID (t.ex. `Kungsbacka.Certificate.<hostname>.CertificateWatcher.Discovery`) samt uppdatera `Hostname`- och `Port`-värdena.
2. Duplicera den monitor som passar och byt ut ID:n inklusive alertmeddelandet (följ samma mönster som `...rbokKungsbackaSe...` eller `...passboltKbaLocal...`) så att varje certifikat får en unik monitor- och strängidentitet.
3. Utöka vy-paketet med ytterligare vyer eller kolumner för de nya certifikaten vid behov.

Kom ihåg att uppdatera `LanguagePack`-sektionerna i respektive Management Pack med namn och beskrivningar för varje nytt objekt.
