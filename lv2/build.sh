#!/bin/bash
set -e
name=lv2
repo=$name/$name
homepage="https://lv2plug.in/"
description="Plugin standard for audio systems."
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://lv2plug.in/spec/$filename"
unpk_enter "$filename" "$direname"
sed -i -e '/eg-sampler.lv2/d' -e '/eg-scope.lv2/d' plugins/meson.build
mni --prefix=/usr -D docs=disabled
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
