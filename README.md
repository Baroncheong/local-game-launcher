# Local Game Launcher

A tiny, offline game library for Windows. Point it at the folders where your games live and it shows every game as a cover card; click one to start it. No install, no account, no internet needed.

The interface text is in Traditional Chinese (Cantonese).

## Features

- **Auto-scan**: each subfolder of a games folder becomes one game. The launcher picks the game's exe and skips helpers such as `UnityCrashHandler`, `Config` and installers. A version or DLC layout like `Game\v1.0` and `Game\DLC - Extra` works too: main folders are tried before `DLC - ...` ones.
- **Covers**: put `<game folder name>.jpg/png/webp/gif` in `covers\`, or click a game and choose **換封面** (change cover) to pick any image.
- **Game pop-up**: start directly, start with MTool, open the game's folder, or change its cover. The pop-up also shows where the game is.
- **Import archives**: pick one or more zip/rar/7z files, with an optional password. They are extracted into a games folder, extra wrapper folders are removed, and the archive is moved to your archive folder (`Game Zips\<game>` by default).
- **Add by exe**: add a game that lives anywhere by picking its exe. Nothing is moved.
- **Settings window (⚙ 設定)**: title, games folders, archive folder, MTool folder, and a filter that hides folders by name.
- Works with XUnity AutoTranslator: if a game folder has a `* (Patch and Run).lnk`, it is used to start the game.

## Requirements

- Windows 10/11. It uses the built-in `mshta.exe`.
- [7-Zip](https://www.7-zip.org/), installed at `C:\Program Files\7-Zip\7z.exe`. Only the archive import needs it.
- Optional: MTool, for the "start with MTool" button.

## Getting started

1. Download or clone this repository anywhere, for example `C:\LocalGameLauncher`.
2. Run `LocalGameLauncher.exe`. You can also double-click `LocalGameLauncher.hta`.
3. Open **⚙ 設定**, add your games folders with **＋ 揀資料夾**, then click **儲存** (save).
4. Optional: right-click the exe and choose **Show more options → Pin to taskbar**.

Your settings (`config.txt`), the list of added games (`extra-games.txt`), your covers and your archives stay on your PC. They are git-ignored.

## Renaming

`LocalGameLauncher.exe` opens the `.hta` file that has the same name. To rename the app, rename both files, for example `MyGames.exe` and `MyGames.hta`.

## Building the exe yourself

The exe is a small wrapper that starts `mshta`. Its source is in `src\LocalGameLauncher.cs`. To build it with the C# compiler that comes with Windows:

```bat
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /nologo /target:winexe /win32icon:logo.ico /out:LocalGameLauncher.exe src\LocalGameLauncher.cs
```

## Notes

- MTool cannot be told which game to open. The MTool button opens MTool, selects the game's exe in Explorer and copies its path, so you can drag it in or paste it.
- Windows may one day remove `mshta`. If that happens, this launcher will need a rewrite.

## License

MIT
