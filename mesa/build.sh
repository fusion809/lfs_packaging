#!/bin/bash
name=mesa
version=$(wget -cqO- https://mesa3d.org/ | grep "relnotes" | head -n 1 | cut -d '/' -f 5 | sed 's/.html.*//g')
direname="$name-$version"
filename="$direname.tar.xz"
depends=(xorg-libs)
blfs_depends=(libdrm mako pyyaml glslang libva llvm wayland-protocols libclc vulkan-loader cbindgen make-ca rust-bindgen)

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

