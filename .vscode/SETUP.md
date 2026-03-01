# DIGI405 Workspace Setup Documentation

**Last Updated:** February 27, 2026

## VS Code Installation

- **Installation Path:** `d:\VSCode`
- **User Data:** `d:\VSCode\data`
- **Extensions:** `d:\VSCode\data\extensions`
- **Binary Path:** `D:\Apps\vscode\bin` (in PATH)

## Installed Extensions

### Active Extensions (Latest Versions)

1. **github.copilot-chat** - `0.37.9`
   - AI pair programmer (chat interface)
   - Also installed: 0.37.8

2. **james-yu.latex-workshop** - `10.13.1`
   - LaTeX document editing and compilation
   - Also installed: 10.13.0

3. **ms-python.debugpy** - `2025.18.0-win32-x64`
   - Python debugger

4. **ms-python.python** - `2026.2.0-win32-x64`
   - Python language support

5. **ms-python.vscode-pylance** - `2026.1.1`
   - Python language server with IntelliSense

6. **ms-python.vscode-python-envs** - `1.20.1-win32-x64`
   - Python environment management

7. **ms-vscode.powershell** - `2025.4.0`
   - PowerShell language support

8. **reditorsupport.r** - `2.8.6`
   - R language support

9. **reditorsupport.r-syntax** - `0.1.3`
   - R syntax highlighting

10. **shd101wyy.markdown-preview-enhanced** - `0.8.20`
    - Enhanced Markdown preview

11. **tomoki1207.pdf** - `1.2.2`
    - PDF viewer

12. **yzhang.markdown-all-in-one** - `3.6.3`
    - All-in-one Markdown support

## Development Tools in PATH

### Core Development Tools

- **VS Code:** `D:\Apps\vscode\bin`
- **VS Code Data:** `d:\VSCode\data\user-data\User\globalStorage\github.copilot-chat\`
  - `debugCommand`
  - `copilotCli`

### PowerShell

- **PowerShell 7:** `D:\Program Files\PowerShell\7\`
- **Windows PowerShell:** `C:\Windows\System32\WindowsPowerShell\v1.0\`
- **Windows PowerShell (System32):** `C:\WINDOWS\System32\WindowsPowerShell\v1.0\`

### Python

- **Python Launcher:** `C:\Users\david\AppData\Local\Programs\Python\Launcher\`
- **Python Debugpy Scripts:** `d:\VSCode\data\extensions\ms-python.debugpy-2025.18.0-win32-x64\bundled\scripts\noConfigScripts`

### R and Statistics

- **Strawberry Perl:**
  - `D:\Strawberry\c\bin`
  - `D:\Strawberry\perl\site\bin`
  - `D:\Strawberry\perl\bin`
- **RTools:** `D:\rtools44`
- **RStudio:** `D:\Program Files\RStudio`

### LaTeX

- **MiKTeX:** `D:\MiKTeX\miktex\bin\x64\`
- **Pandoc:** `C:\Program Files\Pandoc\`

### Other Tools

- **Node.js:** `D:\Program Files\nodejs\`
- **Java JDK:** `C:\Program Files\Eclipse Adoptium\jdk-11.0.26.4-hotspot\bin`
- **Chocolatey:** `d:\ProgramData\chocolatey\bin`
- **FFmpeg:** `D:\ProgramData\chocolatey\lib\ffmpeg\tools`
- **Tesseract OCR:** `C:\Program Files\Tesseract-OCR`
- **.NET:** `C:\Program Files\dotnet\`

### Intel/System Components

- Intel Management Engine Components (iCLS, DAL, IPT)
- NVIDIA PhysX Common

## Workspace Configuration

### LaTeX Workshop Settings

Located in `.vscode/settings.json`:

#### Recipes
- **XeLaTeX** (default)
- **XeLaTeX x2** (default recipe)
- **pdfLaTeX**

#### LaTeX Tools
- **xelatex:** Uses `-synctex=1`, `-interaction=nonstopmode`, `-file-line-error`
- **pdflatex:** Uses `-synctex=1`, `-interaction=nonstopmode`, `-file-line-error`

#### Build Settings
- **Auto Build:** On save
- **PDF Viewer:** Tab
- **Auto Clean:** Enabled

#### Clean File Types
Automatically removes auxiliary files:
- `*.aux`, `*.bbl`, `*.blg`, `*.idx`, `*.ind`
- `*.lof`, `*.lot`, `*.out`, `*.toc`
- `*.acn`, `*.acr`, `*.alg`, `*.glg`, `*.glo`, `*.gls`
- `*.fls`, `*.log`, `*.fdb_latexmk`
- `*.snm`, `*.synctex*`, `*.nav`

## Environment Variables

### Key Environment Variables

- `PATH`: Contains all development tools listed above
- User-specific paths: `C:\Users\david\AppData\Local\Microsoft\WindowsApps`

## Workspace Structure

```
DIGI405/
├── .vscode/
│   ├── settings.json          # LaTeX Workshop configuration
│   ├── keybindings.json       # Custom keybindings
│   └── SETUP.md               # This file
├── corpus-analysis-labs-1.0.2/
│   └── corpus-analysis-labs-1.0.2/
│       ├── DIGI405 - Lab 1.1 - Frequency.ipynb
│       ├── DIGI405 - Lab 1.2 - Concordancing.ipynb
│       ├── DIGI405 - Lab 2.1 - Collocations.ipynb
│       ├── DIGI405 - Lab 2.2 - Ngrams.ipynb
│       ├── DIGI405 - Lab 2.3 - Keywords.ipynb
│       └── DIGI405 - loading and building corpora.ipynb
├── course-materials/
│   └── module-1-text-fundamentals/
├── scripts/
│   ├── analyze_corpus.py
│   ├── extract_screenshots_ocr.R
│   ├── extract_text_from_screenshots.ps1
│   ├── extract_text_from_screenshots.py
│   └── scrape_webpages_to_corpus.py
├── DIGI405.code-workspace     # VS Code workspace file
└── README.md

```

## Notes

- Multiple versions of some extensions are kept (GitHub Copilot Chat, LaTeX Workshop)
- VS Code is installed in a non-standard location (`d:\VSCode`)
- Most development tools are installed on D: drive
- Comprehensive text processing stack: Python, R, LaTeX, OCR (Tesseract)
- Markdown support with multiple extensions for different features

## Recommended Actions

1. **Update Extensions:** Several extensions may have updates available
2. **Clean Old Versions:** Remove older versions of extensions if not needed
3. **Add to PATH:** Consider adding Python and R executables to PATH for easier command-line access
4. **Environment Setup:** Document specific Python and R versions being used

## Maintenance

To update this file:
1. Check current extensions: `code --list-extensions --show-versions`
2. Check PATH: `$env:Path -split ';'`
3. Update version numbers and paths as needed
