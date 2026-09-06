#!/bin/bash
set -e
name=gnome-settings
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 colord e2fsprogs expat fontconfig freetype gcc gdk-pixbuf glib2 glibc glycin gnome-desktop icu json-glib keyutils libX11 libXfixes libffi libgcrypt libgpg-error libgudev libidn2 libnotify libpng libpsl libunistring libxcrypt libxkbcommon libxml2 mitkrb networkmanager nghttp2 nspr nss openssl p11-kit pcre2 polkit sqlite systemd util-linux zlib)
blfs_depends=(alsa-lib avahi cups flac gcr4 geoclue geocode-glib lame lcms2 libXau libXdmcp libcanberra libgweather libogg libseccomp libsndfile libsoup libvorbis libxcb modemmanager mpg123 opus pulseaudio upower webkitgtk)
lfs_depends=(dbus)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
