#!/bin/bash
set -e
name=zed
repo=zed-industries/$name
homepage="https://zed.dev"
description="High-performance, multiplayer code editor."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cargo build --release
sudo cp -r crates/$name/resources/$name.desktop.in /usr/share/applications/$name.desktop
sudo sed -i \
    -e 's|Icon=.*$|Icon=zed|g' \
    -e 's|TryExec=.*$|TryExec=zed|g' \
    -e 's|^Exec=\$APP_CLI \$APP_ARGS|Exec=zed %f|g' \
    -e 's|^Exec=\$APP_CLI --new \$APP_ARGS|Exec=zed --new %f|g' \
    -e 's|^Name=\$APP_NAME|Name=zed|g' \
    -e 's|^StartupNotify=.*$|StartupNotify=true|g' \
    /usr/share/applications/$name.desktop
sudo cp -r crates/zed/resources/app-icon.png /usr/share/pixmaps/$name.png
sudo cp -r target/release/$name /usr/bin
sudo cp -r assets/images/zed_logo.svg /usr/share/icons/hicolor/scalable/apps/$name.svg
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
