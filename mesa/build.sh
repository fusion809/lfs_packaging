#!/bin/bash
name=mesa
get_version() {
      local up_ver=$(wget -T 5 -cqO- https://mesa3d.org/ | grep "relnotes" | head -n 1 | cut -d '/' -f 5 | sed 's/.html.*//g')
      ver_check "$up_ver" && return

      local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/mesa/mesa.git | grep -E "refs/tags/mesa-[0-9.]+$" | cut -d '-' -f 2 | sort -V | tail -n 1)
      ver_check "$git_ver" && return

      local arch_ver=$(aver $name)
      ver_check "$arch_ver" && return
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

