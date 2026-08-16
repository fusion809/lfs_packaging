#!/bin/bash
set -e
name=antigravity
depends=(elfutils glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libxkbfile mesa mitkrb openldap orc pango pcre2 wayland)
lfs_depends=(bash bzip2 coreutils dbus e2fsprogs expat gcc glibc libelf libffi libxcrypt openssl sed sqlite systemd tar util-linux xz zlib zstd)
blfs_depends=(alsa-lib at-spi2-core avahi brotli cairo cups curl cyrus-sasl dav1d enchant fontconfig freetype fribidi gdk-pixbuf glycin graphite2 gst-plugins-base gstreamer harfbuzz highway keyutils lcms2 libXau libXdmcp libaom libarchive libavif libdrm libepoxy libgcrypt libgpg-error libidn2 libjpeg-turbo libjxl libpng libpsl libseccomp libsecret libsoup libtasn1 libunistring libunwind libwebp libx11 libxcb libxkbcommon libxkbfile libxml2 libxslt nghttp2 nspr nss pixman svt-av1 webkitgtk wget)
version=$(wget -cqO- "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=antigravity-ide" | grep "^pkgver=" | sed 's/^pkgver=//g')
_build=$(wget -cqO- "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=antigravity-ide" | grep "^_build=" | sed 's/^_build=//g')

filename="Antigravity IDE.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/$version-$_build/linux-x64/$filename"
fi
rm -rf "$direname"
tar xf "$filename"
sudo mkdir -p /usr/share/antigravity
sudo ln -sf /usr/share/antigravity/bin/antigravity-ide /usr/bin/
sudo ln -sf /usr/share/antigravity/bin/antigravity-ide /usr/bin/antigravity
sudo cp -r "$direname"/* /usr/share/antigravity
sudo cp $name.desktop /usr/share/applications/
sudo cp $name.png /usr/share/pixmaps/
sudo rm -rf "$direname" "$filename"
echo $version > /var/lib/custom-packages/$name
