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

Copy `zed/settings.json` and `zed/keymap.json` into `%APPDATA%\Zed` on Windows. Merge them with any local preferences or bindings you want to keep.

**Ctrl+B** toggles the right sidebar in Vim normal and insert modes.

### Explorer folder tree on Windows

Right-click a file in Explorer and choose **Open with Zed** to open it inside a workspace rooted at its containing folder.

Use Zed's standard per-user Windows installation, Nilesoft Shell 1.9.15 or newer, and Python 3 with `pythonw.exe` on PATH. Run `Get-Command pythonw.exe` in PowerShell to check the Python path.

1. Copy `zed/open-with-tree.pyw` into `%APPDATA%\Zed`.
2. Copy `zed/zed-folder-tree.nss` into the `imports` directory under the Nilesoft Shell installation. The standard location is `C:\Program Files\Nilesoft Shell\imports`.
3. Add this line once to Nilesoft's `shell.nss`:

   ```
   import 'imports/zed-folder-tree.nss'
   ```

4. Hold **Ctrl** and right-click an empty area of the taskbar to reload the menu. [Nilesoft reload instructions](https://nilesoft.org/docs/get-started)

If Zed asks whether to trust a new folder, you can stay in Restricted Mode and still browse its tree. To remove the integration, remove the import from `shell.nss` and reload the menu.
