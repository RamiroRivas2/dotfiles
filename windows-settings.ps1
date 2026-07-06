# windows-settings.ps1 - Windows translation of configuration.nix system.defaults.
# OPTIONAL and separate from bootstrap.ps1 on purpose: these change how
# Windows itself looks and feels. Read through it, delete what you don't
# want, then run:  pwsh -File .\windows-settings.ps1
# It restarts Explorer at the end so the changes show up.

$ErrorActionPreference = 'Stop'

# dark mode everywhere (AppleInterfaceStyle = "Dark")
$personalize = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
Set-ItemProperty $personalize -Name AppsUseLightTheme -Value 0
Set-ItemProperty $personalize -Name SystemUsesLightTheme -Value 0
Write-Host 'dark mode: on'

# fast key repeat, short delay (KeyRepeat = 2, InitialKeyRepeat = 15)
# takes full effect after you sign out and back in
Set-ItemProperty 'HKCU:\Control Panel\Keyboard' -Name KeyboardDelay -Value '0'
Set-ItemProperty 'HKCU:\Control Panel\Keyboard' -Name KeyboardSpeed -Value '31'
Write-Host 'key repeat: fast (full effect after next sign-in)'

# always show file extensions (AppleShowAllExtensions = true)
$advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $advanced -Name HideFileExt -Value 0
Write-Host 'file extensions: always visible'

# auto-hide the taskbar (dock.autohide + _HIHideMenuBar)
$stuck = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
$v = (Get-ItemProperty $stuck).Settings
$v[8] = 3
Set-ItemProperty $stuck -Name Settings -Value $v
Write-Host 'taskbar: auto-hide'

# clean desktop - hide desktop icons (finder.CreateDesktop = false)
Set-ItemProperty $advanced -Name HideIcons -Value 1
Write-Host 'desktop icons: hidden'

# restart Explorer to apply
Stop-Process -Name explorer -Force -Confirm:$false
Write-Host "`nExplorer restarted - settings applied."
