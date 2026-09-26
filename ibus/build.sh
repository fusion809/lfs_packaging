#!/bin/bash
set -e
name=ibus
homepage="https://github.com/ibus/ibus/wiki"
description="Intelligent input bus for Linux/Unix"
repo=$name/$name
version=$(gh_ver "$repo")
filename="$name-$version.tar.gz"
direname="$name-$version"
depends=(at-spi2-core bash brotli bzip2 cairo coreutils dbus dconf elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf gettext glib2 glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk3 gtk4 gzip harfbuzz iso-codes lcms2 libdrm libelf libepoxy libffi libgudev libjpeg-turbo libnotify libnotify libpciaccess libpng libseccomp libsoup libtiff libunwind libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres libxshmfence libxxf86vm llvm lm-sensors mesa orc pango pcre2 pixman python spirv-tools systemd tar util-linux vala vulkan-loader wayland wget xz zip zlib zstd)
gha_download "$repo" "$version" "$filename"
LFS_URL="https://www.linuxfromscratch.org/blfs/view/systemd/general/ibus.html"
UCD_URL=$(wget -T 5 -t 1 -cqO- $LFS_URL \
| grep zip \
| cut -d '"' -f 2 \
| head -n 1)
download_src "$UCD_URL"
unpk_enter "$filename" "$direname"
python3 -m zipfile -e ../UCD.zip /usr/share/unicode/ucd
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
echo "$version" | sudo tee /var/lib/custom-packages/$name
