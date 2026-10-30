#!/bin/bash
set -e
name=scotch
repo=$name/$name
url="https://gitlab.inria.fr/$repo.git"
get_version() {
	local up_ver=$(timeout 5 git ls-remote --tags --refs $url | grep "refs/tags/v[0-9.]+" -oE | sed 's/.*v//g' | sort -V | tail -n 1)
	local inst_ver=$(pkgver $name)
	local archver=$(aver $name)
	ver_check "$up_ver" "$inst_ver" "$archver" && return
	fver "$name" "$inst_ver"
}
homepage="https://gitlab.inria.fr/scotch/scotch"
description="Package for graph partitioning and clustering, and sparse matrix ordering."
version=$(get_version)
filename="$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "$homepage/-/archive/v$version/$filename"
unpk_enter "$filename" "$direname"
arch_patch "$name" fortify-source.patch
arch_patch "$name" scotchconfig.patch
cmake_options=(-G Ninja
    -W no-dev
    -DCMAKE_BUILD_TYPE=None
    -DCMAKE_INSTALL_PREFIX=/usr
    # install in private include directory to avoid conflict with metis and parmetis (metis.h and parmetis.h)
    -DCMAKE_INSTALL_INCLUDEDIR=include/scotch
    -DBUILD_SHARED_LIBS=ON
    -DPTHREAD_AFFINITY_LINUX_OK=ON
    # Explicitly link against internal error libraries to avoid users having to link them manually
    # (the build skips them because of the "--as-needed" linker flag).
    # See https://gitlab.archlinux.org/archlinux/packaging/packages/scotch/-/work_items/2
    -DLIBSCOTCHERR=scotcherr
    -DLIBPTSCOTCHERR=ptscotcherr
  )
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
