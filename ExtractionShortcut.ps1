# CreateExtractShortcut.ps1
# Run once (right-click -> Run with PowerShell)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName PresentationFramework

function Show-Error($msg) { [System.Windows.MessageBox]::Show($msg, "Extract Shortcut", "OK", "Error") | Out-Null }

$installDir = "$env:APPDATA\ExtractShortcut"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
$ahkScript  = "$installDir\Extract.ahk"
$startupLnk = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ExtractShortcut.lnk"

# This AHK script uses COM directly to extract — no PowerShell spawn, much faster
$ahkContent = @'
#Requires AutoHotkey v1.1
#SingleInstance Force
#NoEnv
#Persistent

^!x::
    selectedFile := ""
    for window in ComObjCreate("Shell.Application").Windows() {
        try {
            path := window.Document.FocusedItem.Path
        } catch {
            continue
        }
        if (path != "") {
            selectedFile := path
            break
        }
    }

    if (selectedFile = "")
        return

    SplitPath, selectedFile, , dir, ext, nameNoExt
    StringLower, extLow, ext
    if (extLow != "zip")
        return

    destFolder := dir . "\" . nameNoExt

    ; Use Shell.Application COM to extract — no PowerShell, instant
    if !FileExist(destFolder)
        FileCreateDir, %destFolder%

    shell := ComObjCreate("Shell.Application")
    zip   := shell.NameSpace(selectedFile)
    dest  := shell.NameSpace(destFolder)
    dest.CopyHere(zip.Items(), 4|16)  ; 4=no progress, 16=auto-yes on overwrite

    Run, explorer.exe "%destFolder%"
return
'@

$ahkContent | Set-Content -Path $ahkScript -Encoding UTF8

$ahkExe = ""
$candidates = @(
    "$env:ProgramFiles\AutoHotkey\AutoHotkey.exe",
    "${env:ProgramFiles(x86)}\AutoHotkey\AutoHotkey.exe",
    "$env:LocalAppData\Programs\AutoHotkey\AutoHotkey.exe"
)
foreach ($c in $candidates) { if (Test-Path $c) { $ahkExe = $c; break } }

if (-not $ahkExe) {
    $installer = "$env:TEMP\ahk_setup.exe"
    try {
        Invoke-WebRequest -Uri "https://www.autohotkey.com/download/ahk-install.exe" -OutFile $installer -UseBasicParsing
        Start-Process $installer -ArgumentList "/S" -Wait
    } catch {
        Show-Error "Could not download AutoHotkey. Please install it from https://www.autohotkey.com then run this script again."
        exit 1
    }
    foreach ($c in $candidates) { if (Test-Path $c) { $ahkExe = $c; break } }
    if (-not $ahkExe) {
        Show-Error "AutoHotkey installed but not found. Please restart and try again."
        exit 1
    }
}

$shell = New-Object -ComObject WScript.Shell
$lnk   = $shell.CreateShortcut($startupLnk)
$lnk.TargetPath       = $ahkExe
$lnk.Arguments        = "`"$ahkScript`""
$lnk.WorkingDirectory = $installDir
$lnk.Description      = "Extract ZIP shortcut Ctrl+Alt+X"
$lnk.Save()

Get-Process AutoHotkey -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 500
Start-Process $ahkExe "`"$ahkScript`""
