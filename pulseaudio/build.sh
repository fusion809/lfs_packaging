#!/bin/bash
set -e
name=pulseaudio
repo=$name/$name
version=$(gh_ver $repo)
depends=(alsa-lib avahi bzip2 dbus elfutils flac gcc gdbm glib2 glibc gst-plugins-base gstreamer jack lame libcap libelf libffi libICE libogg libSM libsndfile libunwind libvorbis libX11 libXau libxcb libXdmcp libXext libXi libXtst mpg123 openssl opus orc pcre2 speed systemd util-linux webkitgtk xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.freedesktop.org/software/pulseaudio/releases/$filename
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
