#!/bin/bash
set -e
name=antigravity
depends=(alsa-lib at-spi2-core avahi bash brotli bzip2 cairo coreutils cups curl cyrus-sasl dav1d dbus e2fsprogs elfutils enchant expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gst-plugins-base gstreamer gtk3 harfbuzz highway keyutils lcms2 libaom libarchive libavif libdrm libelf libepoxy libffi libgcrypt libgpg-error libidn2 libjpeg-turbo libjxl libpng libpsl libseccomp libsecret libsoup libtasn1 libunistring libunwind libwebp libx11 libX11 libXau libxcb libXcomposite libxcrypt libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxkbfile libxkbfile libxml2 libXrandr libXrender libXres libxslt mesa mitkrb nghttp2 nspr nss openldap openssl orc pango pcre2 pixman sed sqlite svt-av1 systemd tar util-linux wayland webkitgtk wget xz zlib zstd)
version=$(wget -cqO- "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=antigravity-ide" | grep "^pkgver=" | sed 's/^pkgver=//g')
_build=$(wget -cqO- "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=antigravity-ide" | grep "^_build=" | sed 's/^_build=//g')
filename="Antigravity IDE.tar.gz"
direname="${filename/.tar.gz/}"
download_src "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/$version-$_build/linux-x64/$filename"
unpk_enter "$filename" "$direname"
sudo mkdir -p /usr/share/antigravity
sudo ln -sf /usr/share/antigravity/bin/antigravity-ide /usr/bin/
sudo ln -sf /usr/share/antigravity/bin/antigravity-ide /usr/bin/antigravity
sudo cp -r * /usr/share/antigravity
sudo cp ../$name.desktop /usr/share/applications/
sudo cp ../$name.png /usr/share/pixmaps/
cd ..
sudo rm -rf "$direname" "$filename"
echo $version | sudo tee /var/lib/custom-packages/$name
