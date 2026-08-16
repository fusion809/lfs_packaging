#!/bin/bash
name=mesa
get_version() {
      local up_ver=$(wget -T 5 -cqO- https://mesa3d.org/ | grep "relnotes" | head -n 1 | cut -d '/' -f 5 | sed 's/.html.*//g')
      if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
            echo "$up_ver"
            return 0
      fi

      local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/mesa/mesa.git | grep -E "refs/tags/mesa-[0-9.]+$" | cut -d '-' -f 2 | sort -V | tail -n 1)
      if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
            echo "$git_ver"
            return 0
      fi

      local arch_ver=$(aver $name)
      if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
            echo "$arch_ver"
            return 0
      fi
}
version=$(get_version)
direname="$name-$version"
filename="$direname.tar.xz"
depends=(coreutils meson ninja tar wayland-protocols xorg-libs xz)
lfs_depends=(linux)
blfs_depends=(libdrm mako glslang libva llvm libclc vulkan-loader cbindgen make-ca rust-bindgen)
pip_depends=(pyyaml)

if ! [[ -f $filename ]]; then
	wget -c https://mesa.freedesktop.org/archive/$filename
fi

tar xf $filename
cd $direname
mkdir build &&
cd    build &&

XORG_PREFIX=/usr
meson setup ..                 \
      --prefix=$XORG_PREFIX    \
      --buildtype=release      \
      -D platforms=x11,wayland \
      -D gallium-drivers=auto  \
      -D vulkan-drivers=auto   \
      -D valgrind=disabled     \
      -D video-codecs=all      \
      -D libunwind=disabled    &&

ninja -j$(nproc)
sudo ninja install
sudo cp -rv ../docs -T /usr/share/doc/$direname
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name

