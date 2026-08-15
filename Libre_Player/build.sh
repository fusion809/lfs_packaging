#!/bin/bash
set -e
name=Libre_Player
version=$(git ls-remote https://github.com/Procurador1337/Libre_Player.git HEAD | awk '{print $1}')
direname=$name
blfs_depends=(cmake qt6)

if ! [[ -d $direname/.git ]]; then
	git clone https://github.com/Procurador1337/Libre_Player
fi

cd $direname
git stash
git pull origin main
common_cmake_args=(
  -DCMAKE_BUILD_TYPE=None
  -DCMAKE_INSTALL_PREFIX=/usr
  -Wno-dev
)
cmake -S . -B build "${common_cmake_args[@]}"
cd build
make -j$(nproc)
sudo make install
cd ../..
sudo install -Dm755 $name.desktop /usr/share/applications/
echo "$version" > /var/lib/custom-packages/$name
