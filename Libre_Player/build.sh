#!/bin/bash
set -e
name=Libre_Player
version=$(git ls-remote https://github.com/Procurador1337/Libre_Player.git HEAD | awk '{print $1}')
direname=$name
blfs_depends=(brotli cmake double-conversion flac fontconfig freetype graphite2 harfbuzz keyutils lame libXau libXdmcp libdrm libogg libpng libsndfile libvorbis libxcb libxkbcommon libxml2 llvm lm-sensors mpg123 opus pulseaudio qt6 spirv-tools)
lfs_depends=(bzip2 dbus e2fsprogs expat gcc glibc libelf libffi openssl systemd xz zlib zstd)
depends=(glib2 libX11 libXext libXxf86vm libpciaccess libxshmfence mesa mitkrb pcre2 wayland)

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
