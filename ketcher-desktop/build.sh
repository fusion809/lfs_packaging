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
npm install
npm run build || echo "Errored; will continue if the required files exist."
if [[ -f dist-electron/linux-unpacked/$name ]]; then
	sudo rm -rf /opt/$name
	sudo cp -a dist-electron/linux-unpacked/ /opt/$name
	sudo mv /opt/$name/usr/share/metainfo/* /usr/share/metainfo
	sudo ln -sf /opt/$name/$name /usr/bin/
	sudo cp flatpak/com.ketcher.desktop.desktop /usr/share/applications
	sudo sed -i -e "s|Ketcher Desktop|$name|g" \
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
