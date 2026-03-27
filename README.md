# Kodi NetSkin Release Flow

Use this workflow to publish TV-testable builds of `skin.bingie`.

## 1) Bump version

```bash
./scripts/set_skin_version.sh 2.0.3
```

## 2) Build Kodi-installable zip

```bash
./scripts/build_skin_zip.sh tvfix1
```

This prints the zip path, for example:

`/Users/oliversnow/intel-dashboard/Kodi-NetSkin/dist/skin.bingie-2.0.3-tvfix1.zip`

## 3) Install on TV

In Kodi on TV:

`Add-ons -> Install from zip file` and choose the built `skin.bingie-*.zip`.

Important: do **not** use GitHub's automatic "Source code (zip)" file.

## 4) Publish to GitHub Releases (recommended)

Upload the built zip from `dist/` as a Release asset.  
Then download that same asset on TV and install from zip.
