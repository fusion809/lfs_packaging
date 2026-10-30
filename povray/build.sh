#!/bin/bash
set -e
name=povray
repo=POV-Ray/$name
homepage="https://www.povray.org/"
description="Script-based raytracer for creating 3D graphics."
version=$(gh_ver $repo)
majMinVer=$(echo $version | cut -d '.' -f1-2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(imath libpng openexr tiff boost)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
rm -frv libraries/ilmbase/Imath
  cd unix
  sed 's/automake --w/automake --add-missing --w/g' -i prebuild.sh
  sed 's/dist-bzip2/dist-bzip2 subdir-objects/g' -i configure.ac
  ./prebuild.sh
  cd ..
  ./bootstrap
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    COMPILED_BY='Linux From Scratch' \
    LIBS="-lboost_thread"
  make CXXFLAGS+='-std=c++11 -lboost_thread -DBOOST_BIND_GLOBAL_PLACEHOLDERS=1 -w'
sudo mkdir -p /usr/share/$name-$majMinVer
sudo cp -r icons include ini scenes scripts "/usr/share/$name-$majMinVer"
sudo su -c "install -Dm755 unix/povray /usr/bin/povray"
if ! [[ -f /etc/povray/$majMinVer/povray.conf ]]; then
	sudo install -Dm644 povray.conf "/etc/povray/$majMinVer/povray.conf"
fi
if ! [[ -f /etc/povray/$majMinVer/povray.ini ]]; then
	sudo install -Dm644 povray.ini "/etc/povray/$majMinVer/povray.ini"
fi
sudo install -Dm644 povray.1 "/usr/share/man/man1/povray.1"

cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
