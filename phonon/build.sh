#!/bin/bash
set -e
name=phonon
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu libX11 libXext libXxf86vm libffi libpciaccess libpng libxkbcommon libxml2 libxshmfence mesa pcre2 systemd wayland xz zlib zstd)
blfs_depends=(flac lame libXau libXdmcp libdrm libogg libsndfile libvorbis libxcb llvm lm-sensors mpg123 opus pulseaudio qt6 spirv-tools)
lfs_depends=(libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.kde.org/stable/$name/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D PHONON_BUILD_QT5=OFF -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
