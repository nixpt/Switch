# 🌗 Switch – Theme Toggle for Linux

Easily switch between **light** ☀️ and **dark** 🌙 themes on Linux with a single command.  
Works with **XFCE4 panel** integration or standalone in the terminal.  

---

## ✨ Features
- Toggle between light and dark themes instantly  
- Works with or without XFCE panel  
- Minimal, fast, and written in pure **Bash**  
- Includes a **wrapper** so you can run `switch` from anywhere  
- Lightweight installer (`install.sh`) – no dependencies  
- Versioning support via `switch --version`  

---

## 📦 Installation  

### 1. Clone the repository
```bash
git clone https://github.com/nixpt/switch.git
cd switch
````

### 2. Make the installer executable

```bash
chmod +x install.sh
```

### 3. Run the installer

```bash
./install.sh
```
This will:
    • Install scripts to ~/.local/share/switch
    • Create config files in ~/.config/switch
    • Generate dynamic icons in ~/.local/share/switch
    • Add a .desktop launcher in ~/.local/share/applications
    • Add a CLI symlink switch to ~/.local/bin/switch
⚠️ Make sure ~/.local/bin is in your $PATH if you want to use the CLI.


## 🚀 Usage
From XFCE Panel
    • Launcher: Add "Switch" from your applications menu.
    • Generic Monitor: Add a Generic Monitor panel item with this command:
      cat ~/.cache/switch-icon.txt

Panel / Desktop Launcher
Click the Switch icon in your XFCE panel or application menu to toggle between dark/light themes.
## 🖥️ XFCE Panel Integration

1. Right-click your XFCE panel → **Panel → Add New Items**
2. Choose **Launcher** → Add
3. Right-click the new launcher → **Properties**
4. Click **+** → Select command:

   ```
   switch
   ```
5. (Optional) Set a custom icon 🌗

Now you can toggle themes directly from the panel.

---
Requirements
    • XFCE desktop environment
    • xfconf-query (part of XFCE)
    • ImageMagick (optional, for dynamic icons)
    • Bash 4+
Without XFCE Panel
You can still use Switch via:
    • Application Menu → "Switch"
    • Or directly in the terminal with the commands above.
⚡ Requirements
    • XFCE
    • xfconf-query (XFCE configuration utility)
    • ImageMagick (for icon generation)
🐞 Troubleshooting
    • Panel not changing? → Use switch --panel
    • Mapping seems wrong? → Run switch --updateconfig to regenerate mappings.
    • Plank schema errors? → Dock support is optional; you can skip --dock.

Command Line
# Toggle theme
switch

# Force choose variant if multiple dark options exist
switch --choose

# Update theme mapping
switch --updateconfig

# Show version
switch --version

# Show help
switch --help

# Show author/license
switch --about
Optional Flags
    • --panel – Toggle panel appearance along with GTK/XFWM theme.
    • --choose – Prompt to select from multiple dark variants.
    • --updateconfig – Rescan installed themes and update mappings.





## 🛠️ Development

### Update version

Edit the `VERSION` value in `install.sh`:

```bash
VERSION="1.0.0"
```

### Create a release

```bash
git tag -a v1.0.0 -m "First stable release"
git push origin v1.0.0
```
🧹 Code Style
    • Scripts are written in bash.
    • Keep functions modular and reusable.
    • Document all new flags in both the script and README.md.
💡 Ideas / Roadmap
    • Improve Plank dock integration.
    • Add support for other desktop environments (GNOME, KDE, etc.).
    • Package for popular distros.

---

## 📜 License

Licensed under the **MIT License**.
Created with ❤️ by [Prabin Thapa](https://github.com/nixpt).

```
