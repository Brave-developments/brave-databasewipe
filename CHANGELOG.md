# Changelog

## [make maintenance kick server-only and remove committed webho] - 2026-10-07

### Fixed
- `Maintenance:clearPlayers` is no longer a network event, so clients can no longer trigger a mass kick of all players.
- Removed the Discord webhook URL that was committed to `config.lua`; replaced with a placeholder to set in your own config.
- Wipe flow now completes when no webhook URL is set instead of silently stopping.
