# WezTerm Config

Custom WezTerm setup for Windows + WSL + PowerShell.

Config location:

```text
%USERPROFILE%\.wezterm.lua
```

## Behavior

- Starts in WSL home: `~`
- Opens maximized
- Uses Cascadia Code with ligatures
- Uses a transparent dark theme
- Keeps tabs always visible
- Uses Windows-style copy, paste, and search
- Includes launcher entries for PowerShell, Windows PowerShell, CMD, and SSH

## Shortcuts

| Shortcut | Action |
|---|---|
| `CTRL + T` | New WSL tab |
| `CTRL + TAB` | Next tab |
| `CTRL + SHIFT + TAB` | Previous tab |
| `CTRL + SHIFT + L` | Open launcher |
| `CTRL + SHIFT + R` | Rename tab |
| `CTRL + C` | Copy selection, otherwise interrupt |
| `CTRL + V` | Paste |
| `CTRL + F` | Search |

## WSL Folder Color Fix

If folders have an unreadable highlighted background, run this once in WSL:

```bash
echo 'export LS_COLORS="$LS_COLORS:di=01;36:ow=01;36:tw=01;36:st=01;36"' >> ~/.bashrc
source ~/.bashrc
```


