#!/bin/bash
set -e
name=gnome-control-center
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 colord curl cyrus-sasl e2fsprogs elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gmp gnutls graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz ibus icu jansson json-glib keyutils libX11 libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libadwaita libcap libepoxy libevdev libffi libfyaml libgcrypt libgpg-error libgudev libidn2 libnotify libpciaccess libpng libpsl libtasn1 libunistring libwacom libxcrypt libxkbcommon libxml2 libxmlb libxshmfence mesa mitkrb nettle networkmanager nghttp2 nspr nss openldap openssl orc p11-kit pango pcre2 polkit sqlite systemd udisks util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(accountsservice avahi cairo colord-gtk cracklib cups flac gcr4 gnome-bluetooth gnome-desktop gsound lame lcms2 libXau libXdmcp libcanberra libdrm libgtop libjpeg-turbo libnma libogg libpwquality librest libseccomp libsecret libsndfile libsoup libtiff libunwind libvorbis libwebp libxcb llvm lm-sensors modemmanager mpg123 opus pixman pulseaudio spirv-tools upower webkitgtk)
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
options=(--prefix=/usr --buildtype=release)
#cmi "${options[@]}"
#cmaki "${options[@]}"
mni "${options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
