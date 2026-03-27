# Kodi NetSkin Release Flow

Use this workflow to publish TV-testable builds of `skin.bingie`.

## Local build flow

### 1) Bump version

```bash
./scripts/set_skin_version.sh 2.0.3
```

### 2) Build Kodi-installable zip

```bash
./scripts/build_skin_zip.sh tvfix1
```

This prints a zip path like:

`/Users/oliversnow/intel-dashboard/Kodi-NetSkin/dist/skin.bingie-2.0.3-tvfix1.zip`

Important: do **not** use GitHub's automatic "Source code (zip)" file in Kodi.

## Apple TV / GitHub hosted repo flow

Apple TV testing works best through a Kodi repository hosted in this GitHub repo.

### 1) Generate/update feed files

```bash
./scripts/publish_omega_feed.sh
```

This updates:

- `omega/addons.xml`
- `omega/addons.xml.md5`
- `omega/repository.oliverskodiskin/repository.oliverskodiskin-1.0.0.zip`
- `omega/skin.bingie/skin.bingie-<version>.zip`

### 2) Commit and push

```bash
git add omega scripts
git commit -m "Publish omega feed for skin.bingie <version>"
git push
```

### 3) Add source in Kodi (one-time)

In Kodi:

`Settings -> File manager -> Add source`

Source URL:

`https://raw.githubusercontent.com/playstationoliver07-dotcom/OliversKodiSkin/main/omega/repository.oliverskodiskin/`

### 4) Install repo add-on (one-time)

In Kodi:

`Add-ons -> Install from zip file -> <that source> -> repository.oliverskodiskin-1.0.0.zip`

### 5) Install/update skin from repository

In Kodi:

`Add-ons -> Install from repository -> Oliver Kodi Skin Repository -> Look and feel -> Skin -> Bingie`
