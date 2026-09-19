# Token Peek

Decode a JWT (or `Bearer` JWT) from the clipboard. The token is never written to disk, UserDefaults, Application Support, or logs.

Menu extra for macOS 14+. It lives on the **right** of the menu bar and does not show a Dock icon.

| | |
|---|---|
| Product | `TokenPeek` |
| Bundle ID | `engineer.badry.tokenpeek` |
| Status item | SF Symbol `key` |
| Panel | opaque ~360×420 pt |

## Features

- Polls the clipboard every 0.5s.
- Strips a leading `Bearer ` and finds `eyJ….….…`.
- Pretty-prints header and payload JSON. Signature is **not** verified; caption **Signature not verified.**
- Shows `exp` / `nbf` / `iat` in the current timezone. Menu title is remaining time (`exp 12m`), `expired`, `invalid`, `JWT`, or `Token Peek`.
- **Copy payload** / **Copy header**.

## Requirements

- macOS 14 Sonoma or later
- Swift 5.9 or later only if you build from source

## Install

Build from source:

```bash
git clone https://github.com/BadryansahBangsawan/token-peek.git
cd token-peek
bash package-app.sh
ditto dist/TokenPeek.app /Applications/TokenPeek.app
xattr -cr /Applications/TokenPeek.app
open /Applications/TokenPeek.app
```

Ad-hoc signed (`codesign -s -`). If Gatekeeper blocks it or says it is damaged, run the `xattr` line above. If still blocked: System Settings → Privacy & Security → Open Anyway.

Do not run `dist/` next to a copy in `/Applications` (same bundle ID).

Enable **Open at Login** from Settings if you want it after reboot.

## How to open

This is an `LSUIElement` extra. Proof it is running is the **key** status item on the **right** of the menu bar.

1. Click that extra. The panel is opaque (~360×420), not a 10px strip.
2. If the bar is full, look behind the Control Center overflow chevron **«**.
3. Double-clicking in Finder/Launchpad does not open a document window. That is expected. There is no Dock icon.

## Usage

- Copy a JWT or `Bearer <jwt>`.
- Header and payload appear as read-only JSON. **Copy payload** / **Copy header**.
- Empty clipboard / not a JWT: **Copy a JWT or Bearer token.**
- **Settings** at the bottom: Open at Login, Quit.

## Permissions

Clipboard read. No Accessibility, Screen Recording, or network.

## Data

Nothing is persisted except Open at Login via `SMAppService`. The token is never saved.

## Privacy

No network. Clipboard text never leaves this Mac.

## Uninstall

Delete `/Applications/TokenPeek.app`. Turn off Open at Login in Settings first if you enabled it.

## Troubleshooting

| What you see | What to do |
|---|---|
| No Dock icon | Click the **key** extra on the right of the menu bar. |
| Extra missing | Overflow **«**, or `open /Applications/TokenPeek.app`. |
| “Damaged” | `xattr -cr /Applications/TokenPeek.app` |
| **Copy a JWT or Bearer token.** | Clipboard is not a three-part JWT. |
| **Invalid JWT encoding.** / **invalid** | Base64URL decode failed. |
| Tiny capsule / only Settings | Reinstall from this repo (panel min height 420). |

## Development

```bash
swift build
swift build -c release --product TokenPeek
```

Layout: `Sources/` (SwiftPM executable), `Info.plist`, `Assets/AppIcon.icns`, `package-app.sh`. Never commit `dist/`. FunTheme.swift is copied verbatim (no shared package).

## License

[MIT](LICENSE)
