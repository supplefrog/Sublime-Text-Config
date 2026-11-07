# Editor Configs

Personal settings for Sublime Text and Zed.

## Sublime Text

### Restore

Copy everything under `Packages/User/`, including the `icons` directory, into your Sublime Text User package directory:

- Windows: `%APPDATA%\Sublime Text\Packages\User`
- macOS: `~/Library/Application Support/Sublime Text/Packages/User`
- Linux: `~/.config/sublime-text/Packages/User`

Install [Package Control](https://packagecontrol.io/installation) and the packages in `Package Control.sublime-settings`, including **Theme - One**, then restart Sublime Text. The current preferences include Package Control in `ignored_packages`; temporarily remove that entry while installing or updating packages.

### Appearance

One Light with the matching One interface theme, Lilex at 12 points, and outlined closed/open folder icons. Install the Lilex font separately, or change `font_face` to a font on your machine.

### Sidebar and Vim

On Windows, **Ctrl+B** toggles the sidebar in both Vintage command and insert modes without changing modes. It takes priority over Vintage's optional Ctrl+B page-up binding. Vintage remains enabled, and files start in command mode.

Opening a standalone file in a window with no project folders automatically shows its containing directory. Existing folder roots are preserved when opening more files. Untitled buffers do not add a folder.

## Zed

### Restore on Windows

Install Zed using its standard per-user installer, Nilesoft Shell 1.9.15 or newer, and Python 3 with `pythonw.exe` on PATH. Clone this repo. From its root, run the following in an elevated PowerShell under the same Windows account that uses Zed.

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\zed\Restore-Zed.ps1 -RestartExplorer
```

The script replaces your Zed settings and keymap with the repo's copies, installs the Explorer launcher, and adds its Nilesoft import. It backs up files it replaces to `%APPDATA%\Zed\restore-backups` and prints the backup folder. For a nonstandard Nilesoft installation, pass `-NilesoftRoot` with the path to the folder containing `shell.nss`.

Add `-WhatIf` to preview the operation. The restart can close File Explorer windows. To reload the menu manually, omit `-RestartExplorer`, then hold **Ctrl** and right-click an empty area of the taskbar. [Nilesoft reload instructions](https://nilesoft.org/docs/get-started)

### Sidebar and Explorer

**Ctrl+B** toggles the right sidebar in Vim normal and insert modes. Right-click a file in Explorer and choose **Open with Zed** to open it inside a workspace rooted at its containing folder.

If Zed asks whether to trust a new folder, you can stay in Restricted Mode and still browse its tree. To remove the Explorer integration, remove the `imports/zed-folder-tree.nss` import from `shell.nss` and reload the menu.
