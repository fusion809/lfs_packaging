#!/bin/bash
set -e
name=libical
homepage="https://github.com/libical/libical"
description="An open source reference implementation of the icalendar data type and serialization format"
repo="$name/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake gcc glib2 glibc icu libffi libxml2 pcre2 vala)
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
      -D CMAKE_INSTALL_PREFIX=/usr  \
      -D CMAKE_BUILD_TYPE=Release   \
      -D LIBICAL_STATIC=NO          \
      -D LIBICAL_BUILD_DOCS=false   \
      -D LIBICAL_GLIB_VAPI=true     \
      -D LIBICAL_JAVA_BINDINGS=OFF  \
      -D LIBICAL_GOBJECT_INTROSPECTION=true)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
