# Local Game Launcher 本機遊戲啟動器

[English](#english) | [中文](#中文)

## English

A tiny, offline game library for Windows. Point it at the folders where your games live and it shows every game as a cover card; click one to start it. No install, no account, no internet needed.

The interface text is in Traditional Chinese (Cantonese).

### Features

- **Auto-scan**: each subfolder of a games folder becomes one game. The launcher picks the game's exe and skips helpers such as `UnityCrashHandler`, `Config` and installers. A version or DLC layout like `Game\v1.0` and `Game\DLC - Extra` works too: main folders are tried before `DLC - ...` ones.
- **Covers**: put `<game name>.jpg/png/webp/gif` in `covers\`, or click a game and choose **換封面** (change cover) to pick any image.
- **Game pop-up**: start directly, start with MTool, open the game's folder, or change its cover. The pop-up also shows where the game is.
- **Import archives**: pick one or more zip/rar/7z files, with an optional password. They are extracted into a games folder, extra wrapper folders are removed, and the archive is moved to your archive folder (`Game Zips\<game>` by default).
- **Add by exe**: add a game that lives anywhere by picking its exe, and choose which category it appears under. Nothing is moved. Each category also has a **＋** button that adds a game straight into it.
- **Settings window (⚙ 設定)**: title, games folders, archive folder, MTool folder, and a filter that hides folders by name.
- Works with XUnity AutoTranslator: if a game folder has a `* (Patch and Run).lnk`, it is used to start the game.

### Requirements

- Windows 10/11. It uses the built-in `mshta.exe`.
- [7-Zip](https://www.7-zip.org/), installed at `C:\Program Files\7-Zip\7z.exe`. Only the archive import needs it.
- Optional: MTool, for the "start with MTool" button.

### Getting started

1. Download or clone this repository anywhere, for example `C:\LocalGameLauncher`.
2. Run `LocalGameLauncher.exe`. You can also double-click `LocalGameLauncher.hta`.
3. Open **⚙ 設定**, add your games folders with **＋ 揀資料夾**, then click **儲存** (save).
4. Optional: right-click the exe and choose **Show more options → Pin to taskbar**.

Your settings (`config.txt`), the list of added games (`extra-games.txt`), your covers and your archives stay on your PC. They are git-ignored.

### Renaming

`LocalGameLauncher.exe` opens the `.hta` file that has the same name. To rename the app, rename both files, for example `MyGames.exe` and `MyGames.hta`.

### Building the exe yourself

The exe is a small wrapper that starts `mshta`. Its source is in `src\LocalGameLauncher.cs`. To build it with the C# compiler that comes with Windows:

```bat
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /nologo /target:winexe /win32icon:logo.ico /out:LocalGameLauncher.exe src\LocalGameLauncher.cs
```

### Notes

- MTool cannot be told which game to open. The MTool button opens MTool, selects the game's exe in Explorer and copies its path, so you can drag it in or paste it.
- Windows may one day remove `mshta`. If that happens, this launcher will need a rewrite.

---

## 中文

一個細小、完全離線的 Windows 遊戲庫。告訴它你的遊戲放在哪些資料夾，它就會把每隻遊戲顯示成一張封面卡，點一下就能開遊戲。不用安裝、不用帳戶、不用上網。

介面文字是繁體中文（粵語）。

### 功能

- **自動掃描**：遊戲資料夾裡的每個子資料夾就是一隻遊戲。啟動器會自動找出遊戲的 exe，並略過 `UnityCrashHandler`、`Config`、安裝程式這類輔助程式。像 `Game\v1.0`、`Game\DLC - Extra` 這種分版本或 DLC 的結構也支援，會先找主程式，再找 `DLC - ...` 資料夾。
- **封面**：把 `<遊戲名>.jpg/png/webp/gif` 放進 `covers\`，或者點遊戲後按 **換封面**，選任何一張圖片。
- **遊戲視窗**：可以直接開、用 MTool 開、打開遊戲資料夾，或者換封面。視窗也會顯示遊戲的位置。
- **匯入壓縮檔**：一次選一個或多個 zip/rar/7z，可以輸入密碼。它會解壓到遊戲資料夾、拿走多餘的外層資料夾，再把壓縮檔搬到你的壓縮檔資料夾（預設是 `Game Zips\<遊戲名>`）。
- **用 exe 加遊戲**：遊戲放在任何地方都可以，選它的 exe 就能加入，還可以選它顯示在哪個類別。遊戲不會被搬走。每個類別旁邊也有一個 **＋** 按鈕，可以直接把遊戲加進該類別。
- **設定視窗（⚙ 設定）**：標題、遊戲資料夾、壓縮檔資料夾、MTool 資料夾，以及按名稱隱藏資料夾的過濾器。
- 支援 XUnity AutoTranslator：如果遊戲資料夾裡有 `* (Patch and Run).lnk`，就會用它來開遊戲。

### 需求

- Windows 10/11。它使用系統內建的 `mshta.exe`。
- [7-Zip](https://www.7-zip.org/)，安裝在 `C:\Program Files\7-Zip\7z.exe`。只有匯入壓縮檔才需要。
- 可選：MTool，用於「用 MTool 開」按鈕。

### 開始使用

1. 把這個 repository 下載或 clone 到任何位置，例如 `C:\LocalGameLauncher`。
2. 執行 `LocalGameLauncher.exe`，也可以直接點兩下 `LocalGameLauncher.hta`。
3. 打開 **⚙ 設定**，用 **＋ 揀資料夾** 加入你的遊戲資料夾，然後按 **儲存**。
4. 可選：在 exe 上按右鍵，選 **顯示更多選項 → 釘選到工作列**。

你的設定（`config.txt`）、自己加的遊戲清單（`extra-games.txt`）、封面和壓縮檔都只留在你的電腦，已經被 git 忽略。

### 改名

`LocalGameLauncher.exe` 會打開同名的 `.hta` 檔。想改名的話，兩個檔案一起改，例如 `MyGames.exe` 和 `MyGames.hta`。

### 自己編譯 exe

exe 只是一個啟動 `mshta` 的小程式，原始碼在 `src\LocalGameLauncher.cs`。用 Windows 內建的 C# 編譯器就能編譯：

```bat
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /nologo /target:winexe /win32icon:logo.ico /out:LocalGameLauncher.exe src\LocalGameLauncher.cs
```

### 注意

- MTool 不能從外面指定要開哪隻遊戲。按 MTool 按鈕會打開 MTool、在檔案總管選好遊戲的 exe，並複製它的路徑，你可以把它拖進去或貼上。
- Windows 將來可能會移除 `mshta`。到時這個啟動器就需要重寫。

## License

MIT
