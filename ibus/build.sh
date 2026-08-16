#!/bin/bash
set -e
source $HOME/lfs_packaging/shared-funcs.sh
name=ibus
version=$(gh_ver "ibus/ibus")
filename="$name-$version.tar.gz"
direname="$name-$version"
blfs_depends=(at-spi2-core brotli cairo dconf fontconfig freetype fribidi gdk-pixbuf glib2 glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz iso-codes lcms2 libXau libXdmcp libdrm libepoxy libgudev libjpeg-turbo libnotify libpng libseccomp libsoup libtiff libunwind libwebp libxcb libxkbcommon libxml2 llvm lm-sensors pixman spirv-tools vala vulkan-loader)
depends=(elfutils glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXxf86vm libnotify libpciaccess libxshmfence mesa orc pango pcre2 wayland)
lfs_depends=(bash bzip2 coreutils dbus expat gcc gettext glibc gzip libelf libffi python systemd tar util-linux wget xz zip zlib zstd)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ibus/ibus/archive/$version/$filename
fi
if ! [[ -f "UCD.zip" ]]; then
	wget -c $(wget -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/general/ibus.html | grep zip | cut -d '"' -f 2 | head -n 1)
fi
sudo rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sudo python3 -m zipfile -e ../UCD.zip /usr/share/unicode/ucd
sed -e 's@/desktop/ibus@/org/freedesktop/ibus@g' \
    -i data/dconf/org.freedesktop.ibus.gschema.xml
export SAVE_DIST_FILES=1
export NOCONFIGURE=1
#sudo ./autogen.sh --disable-gtk2 --disable-python2 --disable-emoji-dict --disable-appindicator &&
sudo autoreconf -fi

configure_options=(
    --prefix=/usr          \
    --sysconfdir=/etc      \
    --disable-python2      \
    --disable-appindicator \
    --disable-gtk2         \
    --disable-emoji-dict
)
sudo chown $USER . -R
cmi "${configure_options[@]}"
sudo gtk-query-immodules-3.0 --update-cache
cd ..
sudo rm -rf "$direname" "$filename" "UCD.zip"
echo "$version" > /var/lib/custom-packages/$name
