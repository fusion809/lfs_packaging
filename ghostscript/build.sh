#!/bin/bash
set -e
name=ghostscript
repo=ArtifexSoftware/ghostpdl-downloads
version=$(gh_ver $repo | sed -E 's/(..)(..)/\1.\2./')
verd=$(echo $version | sed 's/\.//g')
depends=(at-spi2-core avahi brotli bzip2 cairo cups dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz lcms2 libepoxy libffi libICE libjpeg-turbo libpaper libpng libseccomp libSM libtiff libwebp libX11 libXau libxcb libXcomposite libxcrypt libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libXrandr libXrender libXres libXt openjpeg openssl pango pcre2 pixman systemd util-linux wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "gs$verd" "$filename"
unpk_enter "$filename" "$direname"
# Remove system-wide installed dependencies
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
