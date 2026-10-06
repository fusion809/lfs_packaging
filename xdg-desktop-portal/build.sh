#!/bin/bash
set -e
name=xdg-desktop-portal
homepage="https://flatpak.github.io/xdg-desktop-portal/"
description="Desktop integration portals for sandboxed apps."
repo=flatpak/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(brotli bubblewrap bzip2 dbus docutils elfutils expat fontconfig freetype fuse gcc gdk-pixbuf glib2 glibc glycin gst-plugins-base gstreamer json-glib libdrm libffi libgudev libpng libseccomp libunwind orc pcre2 pipewire systemd util-linux xdg-desktop-portal-gnome xz zlib zstd)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D tests=disabled
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
