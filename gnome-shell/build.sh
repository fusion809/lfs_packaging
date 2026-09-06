#!/bin/bash
set -e
name=gnome-shell
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl brotli bzip2 colord e2fsprogs elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gnome-autoar gnome-desktop graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu json-glib keyutils libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXxf86vm libarchive libdisplay-info libepoxy libevdev libffi libgcrypt libgpg-error libgudev libical libidn2 libpciaccess libpng libpsl libunistring libwacom libxkbcommon libxml2 libxshmfence lz4 mesa mitkrb mtdev mutter ncurses networkmanager nghttp2 nspr nss openssl orc p11-kit pango pcre2 polkit readline sqlite systemd util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(at-spi2-core cairo evolution-data-server flac gcr4 gjs lame lcms2 libXau libXdmcp libcanberra libdrm libei libinput libjpeg-turbo libogg libseccomp libsecret libsndfile libsoup libtiff libunwind libvorbis libwebp libxcb llvm lm-sensors lua mpg123 opus pipewire pixman pulseaudio spirv-tools startup-notification webkitgtk xcb-util)
lfs_depends=(dbus libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -e '/(ICalProperty/s/ICalProperty/const &/' \
    -i src/calendar-server/gnome-shell-calendar-server.c
options=(--prefix=/usr --buildtype=release -D tests=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
