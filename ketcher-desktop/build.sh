#!/bin/bash
set -e
name=ketcher-desktop
repo=katalystnord/$name
homepage="https://github.com/katalystnord/ketcher-desktop"
description="Electron desktop app for Ketcher skeletal formula sketcher."
version=$(gh_com $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_git "$homepage.git"
srcdir=$PWD
cd $name
python - <<'PY'
from pathlib import Path

main = Path("electron/main.js")
text = main.read_text(encoding="utf-8")

replacements = [
    (
        "function createWindow() {",
        """function getOpenFilePaths() {
  return process.argv.slice(1)
    .filter((arg) => !arg.startsWith('-'))
    .map((arg) => arg.startsWith('file:') ? url.fileURLToPath(arg) : path.resolve(arg))
    .filter((file) => {
      try { return fs.statSync(file).isFile() } catch (_) { return false }
    })
}

function createWindow(inputFile = null) {""",
    ),
    (
        """  win.webContents.on('did-finish-load', () => {
    for (const script of injectedScripts) {
      win.webContents.executeJavaScript(script).catch(() => {})
    }
  })""",
        """  win.webContents.on('did-finish-load', async () => {
    for (const script of injectedScripts) {
      win.webContents.executeJavaScript(script).catch(() => {})
    }

    if (!inputFile) return
    try {
      const structure = await fs.promises.readFile(inputFile, 'utf8')
      await win.webContents.executeJavaScript(`(async () => {
        const deadline = Date.now() + 60000
        while (!window.ketcher || typeof window.ketcher.setMolecule !== 'function') {
          if (Date.now() > deadline) throw new Error('Ketcher editor did not become ready')
          await new Promise((resolve) => setTimeout(resolve, 100))
        }
        await window.ketcher.setMolecule(${JSON.stringify(structure)})
      })()`)
      win.setTitle(`${path.basename(inputFile)} — Ketcher Desktop`)
    } catch (error) {
      dialog.showErrorBox(
        'Could not open chemical file',
        `${inputFile}\\n\\n${error.message}`,
      )
    }
  })""",
    ),
    (
        "  createWindow()\n\n  app.on('activate', () => {",
        """  const filesToOpen = getOpenFilePaths()
  if (filesToOpen.length) {
    for (const file of filesToOpen) createWindow(file)
  } else {
    createWindow()
  }

  app.on('activate', () => {""",
    ),
]

for old, new in replacements:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"Expected one source patch anchor, found {count}: {old[:80]!r}")
    text = text.replace(old, new, 1)

main.write_text(text, encoding="utf-8")
print(f"Enabled file opening in {main}")
PY
npm install
npm run build || echo "Errored; will continue if the required files exist."
if [[ -f dist-electron/linux-unpacked/$name ]]; then
	sudo rm -rf /opt/$name
	sudo cp -a dist-electron/linux-unpacked/ /opt/$name
	sudo mv /opt/$name/usr/share/metainfo/* /usr/share/metainfo
	sudo ln -sf /opt/$name/$name /usr/bin/
	sudo cp flatpak/com.ketcher.desktop.desktop /usr/share/applications
	sudo sed -i -e "s|StartupWMClass=Ketcher Desktop|StartupWMClass=$name|g" \
		-e "s|Science;Education;|Science;Chemistry;Education;|g" /usr/share/applications/com.ketcher.desktop.desktop
	sudo cp flatpak/icons/256x256.png /usr/share/icons/hicolor/256x256/apps/com.ketcher.desktop.png
	sudo cp flatpak/icons/512x512.png /usr/share/icons/hicolor/512x512/apps/com.ketcher.desktop.png
	sudo cp flatpak/icons/512x512.png /usr/share/pixmaps/com.ketcher.desktop.png
fi
rm -rf dist-electron
rm -rf node_modules
rm -rf ketcher/node_modules
cd ..
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
