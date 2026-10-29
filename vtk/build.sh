#!/bin/bash
set -e
name=vtk
_name=VTK
get_version() {
	local up_ver=$(wget -T 5 -t 1 -cqO- https://vtk.org/download/ | grep "VTK-[0-9.]+" -oE | sed 's|\.$||g' | cut -d '-' -f 2 | head -n 1)
	local inst_ver=$(pkgver $name)
	local mon_ver=$(uver $name)
	ver_check "$up_ver" "$inst_ver" "$mon_ver" && return
	fver "$name" "$inst_ver"
}
repo=$name/$name
homepage="https://vtk.org"
description="Software system for 3D visualization and image processing."
version=$(get_version)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
majMinVer=$(echo $version | cut -d '.' -f1-2)
download_src "https://vtk.org/files/release/$majMinVer/$filename"
unpk_enter "$filename"
cmake_options=(-Wno-dev \
	-G Ninja \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE=Release \
	-DVTK_QT_VERSION=6 \
	-DVTK_WRAP_PYTHON=ON \
	-DVTK_USE_MPI=ON
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
