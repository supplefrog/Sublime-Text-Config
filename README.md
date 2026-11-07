# Sublime Text Config

Personal Sublime Text settings, Vim-compatible sidebar shortcut, One Light appearance, and automatic folder display.

## Restore

Copy everything under `Packages/User/`, including the `icons` directory, into your Sublime Text User package directory:

- Windows: `%APPDATA%\Sublime Text\Packages\User`
- macOS: `~/Library/Application Support/Sublime Text/Packages/User`
- Linux: `~/.config/sublime-text/Packages/User`

Install [Package Control](https://packagecontrol.io/installation) and the packages in `Package Control.sublime-settings`, including **Theme - One**, then restart Sublime Text. The current preferences include Package Control in `ignored_packages`; temporarily remove that entry while installing or updating packages.

## Appearance

One Light with the matching One interface theme, Lilex at 12 points, and outlined closed/open folder icons. Install the Lilex font separately, or change `font_face` to a font on your machine.

## Sidebar and Vim

On Windows, **Ctrl+B** toggles the sidebar in both Vintage command and insert modes without changing modes. It takes priority over Vintage's optional Ctrl+B page-up binding. Vintage remains enabled, and files start in command mode.

Opening a standalone file in a window with no project folders automatically shows its containing directory. Existing folder roots are preserved when opening more files. Untitled buffers do not add a folder.

## Zed

Copy `zed/settings.json` and `zed/keymap.json` into `%APPDATA%\Zed` on Windows. Merge them with any local preferences or bindings you want to keep.

**Ctrl+B** toggles the right sidebar in Vim normal and insert modes. Opening a file with its containing folder from Explorer uses a separate local Nilesoft Shell integration.
