#!/bin/bash
set -e
name=dotnet-bin
_name=dotnet-sdk-10.0
get_version() {
	local up_ver=$(wget -T 5 -t 1 -cqO- https://dotnet.microsoft.com/en-us/download/dotnet/10.0 | grep "SDK 10[0-9.]+" -oE | head -n 1 | cut -d ' ' -f 2)
	local inst_ver=$(pkgver $name)
	local arch_ver=$(aver $_name)
	ver_check "$up_ver" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}
description=".NET core with binary package."
homepage="https://dotnet.microsoft.com/"
version=$(get_version)
depends=(gcc glibc)
filename="dotnet-sdk-$version-linux-x64.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://builds.dotnet.microsoft.com/dotnet/Sdk/$version/$filename"
rm -rf $direname
mkdir $direname
cd $direname
tar xf ../$filename
runtimever=$(ls -ld host/fxr/* | cut -d '/' -f 3)
sudo mkdir -p /usr/share/dotnet/shared /usr/bin /usr/lib
sudo cp -dr --no-preserve='ownership' dotnet host dnx sdk sdk-manifests templates /usr/share/dotnet/
sudo cp -dr --no-preserve='ownership' shared/Microsoft.NETCore.App /usr/share/dotnet/shared/
sudo ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet
sudo ln -sf /usr/share/dotnet/dnx /usr/bin/dnx
sudo ln -sf /usr/share/dotnet/host/fxr/${runtimever}/libhostfxr.so /usr/lib/libhostfxr.so
sudo install -dm 755 /usr/share/dotnet/metadata/workloads/$version
sudo touch /usr/share/dotnet/metadata/workloads/$version/userlocal
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
