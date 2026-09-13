#!/bin/bash
set -e
name=ghostscript
repo=ArtifexSoftware/ghostpdl-downloads
version=$(gh_ver $repo | sed -E 's/(..)(..)/\1.\2./')
verd=$(echo $version | sed 's/\.//g')
depends=(brotli bzip2 dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz libICE libSM libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXt libepoxy libffi libpaper libpng libxcrypt libxkbcommon openssl pango pcre2 systemd util-linux wayland xz zlib zstd)
blfs_depends=(at-spi2-core avahi cairo cups lcms2 libXau libXdmcp libjpeg-turbo libseccomp libtiff libwebp libxcb openjpeg pixman)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/gs$verd/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
rm -rf freetype lcms2mt jpeg libpng openjpeg zlib
./configure --prefix=/usr --disable-compile-inits --with-system-libtiff CFLAGS="${CFLAGS:--g -O3} -fPIC"
make -j$(nproc)
make so -j$(nproc)
sudo make install
sudo su -c "make soinstall                                     &&
install -v -m644 base/*.h /usr/include/ghostscript &&
ln -sfvn ghostscript /usr/include/ps
mv -v /usr/share/doc/ghostscript/$version /usr/share/doc/$direname &&
rmdir /usr/share/doc/ghostscript                                            &&
cp -r examples/ -T /usr/share/ghostscript/$version/examples"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
