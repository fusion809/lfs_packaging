#!/bin/bash
set -e
name=mesa
get_version() {
  local inst_ver=$(pkgver $name)
  local lfs_vers=$(lfs_ver $name)
  local up_ver=$(wget -T 5 -cqO- https://mesa3d.org/ | grep "relnotes" | head -n 1 | cut -d '/' -f 5 | sed 's/.html.*//g')
  ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
  local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/mesa/mesa.git | grep -E "refs/tags/mesa-[0-9.]+$" | cut -d '-' -f 2 | sort -V | tail -n 1)
  ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
  local vat_ver=$(vatver $name)
  ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

  local arch_ver=$(aver $name)
  ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
  fver "$name" "$inst_ver"
}
version=$(get_version)
direname="$name-$version"
filename="$direname.tar.xz"
depends=(bzip2 cbindgen coreutils expat gcc glibc glslang libclc libdisplay-info libdrm libelf libffi libglvnd libpciaccess libva libX11 libXau libxcb libXdmcp libXext libxml2 libxshmfence libXxf86vm linux llvm lm-sensors make-ca mako meson ninja rust-bindgen rustc spirv-llvm-translator spirv-tools systemd tar vulkan-loader wayland wayland-protocols xcb-util-keysyms xorg-libs xz xz zlib zstd)
pip_depends=(pyyaml)
download_src "https://mesa.freedesktop.org/archive/$filename"
unpk_enter "$filename" "$direname"
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
echo "$version" | sudo tee /var/lib/custom-packages/$name

