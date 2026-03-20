# ZipFlash

A Windows utility that lets you extract ZIP files instantly with a single keyboard shortcut — no dialogs, no popups, no friction.

Press **Ctrl + Alt + X** on any selected ZIP in File Explorer. Done.

## Features

- **Instant extraction** — Uses Windows Shell COM directly, no PowerShell spawn on every press
- **Zero popups** — Completely silent, no confirmations or dialogs
- **Auto-open** — Extracted folder opens in File Explorer automatically
- **Startup** — Registers itself on Windows login, always available
- **Lightweight** — A single small AutoHotkey script, no background services or installers

## Installation

1. Download `CreateExtractShortcut.ps1`
2. Right-click it → **Run with PowerShell**
3. That's it — the shortcut is now active

AutoHotkey is installed silently if you don't have it already.

## Usage

1. Open File Explorer
2. Click any ZIP file to select it
3. Press **Ctrl + Alt + X**
4. The ZIP extracts into a folder with the same name, right next to it
5. The folder opens automatically

## How it works

The setup script creates an AutoHotkey `.ahk` script that listens for the shortcut globally. When triggered, it grabs the focused file from File Explorer via Shell COM, extracts it using `Shell.Application.NameSpace().CopyHere()`, then opens the result. No PowerShell process is spawned on extraction — everything runs inside the already-running AutoHotkey instance.

A shortcut to the `.ahk` script is placed in the Windows Startup folder so it reloads on every login.

## Requirements

- Windows 10 or 11
- AutoHotkey v1.1 (installed automatically by the setup script)

## Customizing the shortcut

Open `%APPDATA%\ExtractShortcut\Extract.ahk` in any text editor and change `^!x` to your preferred combination:

| Symbol | Key |
|--------|-----|
| `^` | Ctrl |
| `!` | Alt |
| `+` | Shift |
| `#` | Win |

For example, `^+x` = Ctrl + Shift + X.

After editing, double-click the `.ahk` file to reload it.

## License

MIT
