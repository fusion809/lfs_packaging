#!/bin/bash
set -e
name=woff2
repo=google/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i '/output.h/i #include <cstdint>' src/woff2_out.cc
options=(-D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_BUILD_TYPE=Release         \
      -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -D CMAKE_SKIP_INSTALL_RPATH=ON)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
