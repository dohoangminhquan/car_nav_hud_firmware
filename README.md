# car_nav_hud_firmware

Test firmware update for the Car Nav HUD ESP32.

## Firmware manifest

Consuming apps fetch [manifest.json](manifest.json) over HTTPS to discover
the latest firmware version and download URL. The manifest URL is stable;
the firmware filename embeds the version, so old releases stay reachable
at their original URLs.

- Manifest (always latest): `https://raw.githubusercontent.com/dohoangminhquan/car_nav_hud_firmware/main/manifest.json`
- Firmware (this release):  `https://raw.githubusercontent.com/dohoangminhquan/car_nav_hud_firmware/main/carnavhud-1.0.0.1.bin`

### Manifest fields

| Field         | Type    | Description                                              |
|---------------|---------|----------------------------------------------------------|
| `version`     | string  | Firmware version string.                                 |
| `url`         | string  | Direct HTTPS URL to the `.bin` for this version.         |
| `sha256`      | string  | Lowercase hex SHA-256 of the `.bin`.                     |
| `size`        | integer | Size of the `.bin` in bytes.                             |
| `released_at` | string  | ISO-8601 UTC release timestamp.                          |
| `notes`       | string  | Human-readable changelog for this release.               |

### Releasing a new firmware

1. Drop the new build at the repo root with a versioned filename, e.g.
   `carnavhud-1.0.0.2.bin`.
2. Regenerate the manifest:
   ```sh
   ./tools/update_manifest.sh carnavhud-1.0.0.2.bin 1.0.0.2 "Fix BLE reconnect bug"
   ```
3. Commit the new `.bin` and the updated `manifest.json` together and
   push to `main`. The previous `.bin` can stay in the repo for rollback.

### Consumer-side example

```python
import hashlib, json, urllib.request

MANIFEST_URL = "https://raw.githubusercontent.com/dohoangminhquan/car_nav_hud_firmware/main/manifest.json"

m = json.loads(urllib.request.urlopen(MANIFEST_URL).read())
if m["version"] != installed_version:
    blob = urllib.request.urlopen(m["url"]).read()
    assert hashlib.sha256(blob).hexdigest() == m["sha256"], "checksum mismatch"
    assert len(blob) == m["size"], "size mismatch"
    flash(blob)
```
