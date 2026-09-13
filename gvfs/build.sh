#!/bin/bash
set -e
name=gvfs
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli e2fsprogs gcc gcr4 glib2 glibc icu keyutils libffi libgcrypt libgpg-error libgudev libidn2 libpsl libsecret libunistring libxml2 mitkrb nghttp2 p11-kit pcre2 polkit sqlite systemd udisks util-linux zlib)
blfs_depends=(libcdio libsoup)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release -D onedrive=false   \
      -D fuse=false       \
      -D gphoto2=false    \
      -D afc=false        \
      -D bluray=false     \
      -D nfs=false        \
      -D mtp=false        \
      -D smb=false        \
      -D dnssd=false      \
      -D goa=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
