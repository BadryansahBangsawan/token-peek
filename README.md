<div align="center">

# Token Peek

**Decode a JWT from the clipboard. The token is never written to disk, UserDefaults, logs, or Application Support.**

Menu extra for macOS 14+. Lives on the **right** of the menu bar. No Dock icon.

<br/>

[![Build](https://github.com/BadryansahBangsawan/token-peek/actions/workflows/ci.yml/badge.svg)](https://github.com/BadryansahBangsawan/token-peek/actions/workflows/ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/BadryansahBangsawan/token-peek?style=flat-square)](https://github.com/BadryansahBangsawan/token-peek/releases/latest)
[![macOS](https://img.shields.io/badge/macOS-14%2B-black?style=flat-square&logo=apple)](https://github.com/BadryansahBangsawan/token-peek/releases/latest)

<br/>

![Token Peek panel](docs/panel.png)

| | |
|---|---|
| Product | `TokenPeek` |
| Bundle ID | `engineer.badry.tokenpeek` |
| Status item | SF Symbol `key` (`Token Peek` / `invalid` / `expired` / `JWT` / `exp 45s`) |
| Panel | opaque ~360×420 pt |

</div>

---

## What you get

| Piece | Behavior |
|---|---|
| **Clipboard** | Polls every 0.5s. A leading `Bearer ` is stripped. Three Base64URL segments only. |
| **JSON** | Pretty-prints header and payload. Signature is **not** verified. |
| **Claims** | `exp` / `nbf` / `iat` in the current timezone. Remaining time refreshes every second. |
| **Copy** | **Copy payload** and **Copy header** write that JSON to the clipboard. |
| **Login** | Open at Login from Settings (`SMAppService`). |

---

## Download

| File | Use |
|---|---|
| **`TokenPeek.app.zip`** | Unzip, drag **TokenPeek** onto **Applications** |

**[Releases](https://github.com/BadryansahBangsawan/token-peek/releases/latest)**

---

## Install

### Zip

1. Download `TokenPeek.app.zip` from [Releases](https://github.com/BadryansahBangsawan/token-peek/releases/latest).
2. Unzip. Drag **TokenPeek** onto **Applications**.
3. First open (ad-hoc signed):

```bash
xattr -cr /Applications/TokenPeek.app
open /Applications/TokenPeek.app
```

Still blocked: System Settings → Privacy & Security → Open Anyway.

### Source

```bash
git clone https://github.com/BadryansahBangsawan/token-peek.git
cd token-peek
bash package-app.sh
ditto dist/TokenPeek.app /Applications/TokenPeek.app
xattr -cr /Applications/TokenPeek.app
open /Applications/TokenPeek.app
```

Do not run `dist/TokenPeek.app` while `/Applications/TokenPeek.app` is running (same bundle ID).

---

## How to open

This is an `LSUIElement` extra. Proof it is running is the **key** status item on the **right** of the menu bar, not a window from Finder or Launchpad.

1. Click that extra. The panel is opaque ~360×420 pt, not a 10px strip.
2. If the bar is full, look behind the Control Center overflow chevron **«**.
3. Double-clicking in Finder/Launchpad only changes the left-side app name. That is expected. There is no Dock icon.

---

## Usage

1. Copy a JWT, or `Bearer <jwt>`.
2. Click the extra. Header and payload appear as read-only JSON.
3. **Copy payload** / **Copy header** write that JSON to the clipboard.
4. **Settings** at the bottom: Open at Login, Quit.

Empty clipboard or text that is not a three-part JWT: **No token** / **Copy a JWT or Bearer token.** Menu title `Token Peek`.

| Condition | Title |
|---|---|
| No JWT | `Token Peek` |
| Decode failed | `invalid` |
| `exp` in the past | `expired` |
| No `exp` claim | `JWT` |
| Future `exp` | `exp 45s` / `exp 12m` / `exp 5h` / `exp 3d` |

`nbf` in the future adds a red **Not valid yet.**

This is an inspector, not a verifier. Treat `alg: none` the same as any other algorithm: **Signature not verified.**

---

## Permissions

No TCC prompts. Clipboard is read in-process.

---

## Data

Nothing is persisted except Open at Login via `SMAppService`. The token is never saved.

---

## Privacy

No network. Clipboard text never leaves this Mac.

---

## Uninstall

Delete `/Applications/TokenPeek.app`.

Turn off **Token Peek** in System Settings → General → Login Items if it remains.

---

## Troubleshooting

| What you see | What to do |
|---|---|
| Finder “opens” nothing / no Dock icon | Click the **key** extra on the right of the menu bar. |
| Extra missing | Overflow **«**, or `pgrep -x TokenPeek` then `open /Applications/TokenPeek.app`. |
| “Damaged” / cannot verify | `xattr -cr /Applications/TokenPeek.app`. `spctl --assess` is `rejected` even when it runs. |
| **Copy a JWT or Bearer token.** | Copy a three-part JWT (`eyJ….….…`). |
| **Invalid JWT encoding.** | A segment is not Base64URL. |
| **Invalid JWT JSON.** | Header or payload is not a JSON object. |
| **Signature not verified.** | Intended. This extra does not check signatures. |
| ~10px empty strip under the bar | Reinstall from this repo. |

---

## Build from source

```bash
git clone https://github.com/BadryansahBangsawan/token-peek.git
cd token-peek
swift build -c release --product TokenPeek
bash package-app.sh
open dist/TokenPeek.app
```

Tag `v*` runs CI: `TokenPeek.app.zip`. Never commit `dist/`.

Layout: `Sources/` (SwiftPM executable), `Info.plist`, `Assets/AppIcon.icns`, `package-app.sh`. `FunTheme.swift` is copied verbatim (no shared package).

---

## FAQ

**Why is there no Dock icon?**  
It is a menu extra. Click the key item on the **right** of the menu bar.

**Does this upload the JWT?**  
No. There is no network call. Do not paste the token into jwt.io or other online decoders.

**Where is the token stored?**  
Nowhere. Clipboard only. Nothing under Application Support.

**How do I stop it opening at login?**  
Settings in the panel, or System Settings → General → Login Items → **Token Peek**.

---

<div align="center">

[MIT](LICENSE)

</div>
