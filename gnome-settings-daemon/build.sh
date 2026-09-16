#!/bin/bash
set -e
name=gnome-settings-daemon
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(alsa-lib avahi brotli bzip2 colord cups dbus e2fsprogs expat flac fontconfig freetype gcc gcr4 gdk-pixbuf geoclue geocode-glib glib2 glibc glycin gnome-desktop gnome-settings icu json-glib keyutils lame lcms2 libcanberra libffi libgcrypt libgpg-error libgudev libgweather libidn2 libnotify libogg libpng libpsl libseccomp libsndfile libsoup libunistring libvorbis libX11 libXau libxcb libxcrypt libXdmcp libXfixes libxkbcommon libxml2 mitkrb modemmanager mpg123 networkmanager nghttp2 nspr nss openssl opus p11-kit pcre2 polkit pulseaudio sqlite systemd upower util-linux webkitgtk zlib)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
