#!/bin/bash
set -e
name=LibreWeather
version=$(gh_com "Procurador1337/$name")
depends=(brotli cmake coreutils dbus double-conversion e2fsprogs expat gcc glib2 glibc keyutils libelf libffi make mitkrb openssl pcre2 qt6 systemd zlib zstd)
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
echo "$version" | sudo tee /var/lib/custom-packages/$name
