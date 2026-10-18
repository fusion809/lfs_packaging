#!/bin/bash
set -e
name=nlohmann-json
_name=json
repo=nlohmann/$_name
test_repo=nlohmann/json_test_data
homepage="https://github.com/nlohmann/json"
description="JSON for modern C++."
version=$(gh_ver $repo)
test_version=$(gh_ver $test_repo)
filename="$_name-$version.tar.gz"
test_filename="json_test_data-$test_version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
gha_download "$test_repo" "v$test_version" "$test_filename"
srcdir=$PWD
tar xf "$test_filename"
unpk_enter "$filename" "$direname"
cmake_options=(
    -D BUILD_TESTING=ON
    -D CMAKE_BUILD_TYPE=None
    -D CMAKE_INSTALL_PREFIX=/usr
    -D CMAKE_INSTALL_LIBDIR=/usr/lib
    -D JSON_BuildTests=ON
    -D JSON_TestDataDirectory="$srcdir"/json_test_data-$test_version/
    -D JSON_MultipleHeaders=ON
    -W no-dev
  )
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
