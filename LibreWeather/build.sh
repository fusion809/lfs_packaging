#!/bin/bash
set -e
name=LibreWeather
version=$(gh_com "Procurador1337/$name")
depends=(glib2 mitkrb pcre2)
blfs_depends=(brotli double-conversion keyutils qt6)
lfs_depends=(cmake coreutils dbus e2fsprogs expat gcc glibc libelf libffi make openssl systemd zlib zstd)
direname=$name

if ! [[ -d $direname/.git ]]; then
	git clone https://github.com/Procurador1337/$name
fi

cd $direname
git stash
git pull origin main
common_cmake_args=(
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX=/usr
  -Wno-dev
)
cmaki "${common_cmake_args[@]}"
cd ..
rm -rf build
cd ..
echo "$version" > /var/lib/custom-packages/$name
