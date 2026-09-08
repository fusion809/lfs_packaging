#!/bin/bash
set -e
name=pulseaudio
repo=$name/$name
version=$(gh_ver $repo)
depends=(bzip2 dbus elfutils gcc gdbm glib2 glibc gst-plugins-base gstreamer jack libICE libSM libX11 libXext libXi libXtst libcap libffi openssl orc pcre2 systemd util-linux webkitgtk xz zlib zstd)
blfs_depends=(alsa-lib avahi flac lame libXau libXdmcp libogg libsndfile libunwind libvorbis libxcb mpg123 opus)
lfs_depends=(libelf)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.freedesktop.org/software/pulseaudio/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
meson_options=(--prefix=/usr --buildtype=release -D database=gdbm    \
            -D doxygen=false    \
            -D bluez5=disabled  \
	    -D tests=false)
mni "${meson_options[@]}"
cd ../..
sudo rm /usr/share/dbus-1/system.d/pulseaudio-system.conf
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
