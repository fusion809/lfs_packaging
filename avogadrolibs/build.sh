#!/bin/bash
set -e
name=avogadrolibs
repo=OpenChemistry/$name
homepage="https://two.avogadro.cc/"
description="Libraries that provide 3D modelling, rendering, visualization, analysis, etc."
version=$(gh_ver $repo)
depends=(acl avogadro-crystals avogadro-fragments avogadro-molecules boost brotli bzip2 cmake dbus double-conversion e2fsprogs eigen expat fast_float fontconfig freetype gcc genxrdpattern glew glib2 glibc graphite2 harfbuzz hdf5 icu jkqtplotter-git keyutils libaec libarchive libglvnd libmsym libpng libx11 libxau libxcb libxdmcp libxkbcommon libxml2 lz4 mitkrb mmtf-cpp nlohmann-json onetbb openmpi openssl pcre2 pugixml pybind11 qt6 samba spglib systemd utf8cpp xz zlib zstd)
conflicts=(avogadro2-bin)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
frag_repo=OpenChemistry/fragments
frag_ver=$(gh_ver $frag_repo)
frag_filename="fragments-$frag_ver.tar.gz"
gha_download "$frag_repo" "$frag_ver" "$frag_filename" 
crys_repo=OpenChemistry/crystals
crys_ver=$(gh_ver $crys_repo)
crys_filename="crystals-$crys_ver.tar.gz"
gha_download "$crys_repo" "$crys_ver" "$crys_filename" 
mol_repo=OpenChemistry/molecules
mol_ver=$(gh_ver $mol_repo)
mol_filename="molecules-$mol_ver.tar.gz"
gha_download "$mol_repo" "$mol_ver" "$mol_filename" 
tar xf $frag_filename
mv "${frag_filename/.tar.*/}" fragments
touch fragments/polymers/INSTALL
tar xf $crys_filename
mv "${crys_filename/.tar.*/}" crystals
tar xf $mol_filename
mv "${mol_filename/.tar.*/}" molecules
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_C_FLAGS="$CFLAGS -ffat-lto-objects" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS -ffat-lto-objects" \
    -DUSE_HDF5=ON \
    -DUSE_PYTHON=ON \
    -DUSE_SYSTEM_GENXRDPATTERN=ON \
    -DUSE_EXTERNAL_NLOHMANN=ON \
    -DUSE_EXTERNAL_PUGIXML=ON \
    -DQT_VERSION=6)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$crys_filename" "$frag_filename" "$mol_filename" "$filename" "$direname" molecules fragments crystals
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
