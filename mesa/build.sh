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
depends=(coreutils libX11 libXext libXxf86vm libdisplay-info libpciaccess libxshmfence meson ninja tar wayland wayland-protocols xorg-libs xz)
lfs_depends=(bzip2 expat gcc glibc libelf libffi linux systemd xz zlib zstd)
blfs_depends=(cbindgen glslang libXau libXdmcp libclc libdrm libva libxcb libxml2 llvm lm-sensors make-ca mako rust-bindgen spirv-tools vulkan-loader xcb-util-keysyms rustc spirv-llvm-translator)
pip_depends=(pyyaml)

if ! [[ -f $filename ]]; then
	wget -c https://mesa.freedesktop.org/archive/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
export PATH=$PATH:/opt/rustc/bin
XORG_PREFIX=/usr
meson_options=(
      --prefix=$XORG_PREFIX    \
      --buildtype=release      \
      -D platforms=x11,wayland \
      -D gallium-drivers=auto  \
      -D vulkan-drivers=auto   \
      -D valgrind=disabled     \
      -D video-codecs=all      \
      -D libunwind=disabled
)
mni "${meson_options[@]}"
sudo cp -rv ../docs -T /usr/share/doc/$direname
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name

