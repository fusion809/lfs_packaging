#!/bin/bash
set -e
name=llvm
repo=$name/$name-project
version=$(gh_ver $repo)
depends=(gcc glibc icu libffi libxml2 zlib zstd)
filename="$name-project-$version.src.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/llvm/llvm-project/releases/download/llvmorg-$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
grep -rl '#!.*python$' | xargs sed -i '1s/python$/python3/'
sed 's/utility/tool/' -i llvm/utils/FileCheck/CMakeLists.txt
mkdir -pv /etc/clang &&
for i in clang clang++; do
  echo -fstack-protector-strong > /etc/clang/$i.cfg
done
options=(-D CMAKE_INSTALL_PREFIX=/usr           \
      -D CMAKE_SKIP_INSTALL_RPATH=ON         \
      -D LLVM_ENABLE_FFI=ON                  \
      -D CMAKE_BUILD_TYPE=Release            \
      -D LLVM_BUILD_LLVM_DYLIB=ON            \
      -D LLVM_LINK_LLVM_DYLIB=ON             \
      -D LLVM_ENABLE_RTTI=ON                 \
      -D LLVM_TARGETS_TO_BUILD="host;AMDGPU" \
      -D LLVM_ENABLE_PROJECTS=clang          \
      -D LLVM_ENABLE_RUNTIMES=compiler-rt    \
      -D LLVM_BINUTILS_INCDIR=/usr/include   \
      -D LLVM_INCLUDE_BENCHMARKS=OFF         \
      -D CLANG_DEFAULT_PIE_ON_LINUX=ON       \
      -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang \
      -W no-author -G Ninja)
CC=gcc CXX=g++ cmaki "${options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
