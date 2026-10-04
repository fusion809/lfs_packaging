#!/bin/bash
set -e
name=emacs
repo=$name/$name
homepage="http://www.gnu.org/software/emacs/"
description="The Emacs package contains an extensible, customizable, self-documenting real-time display editor."
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gnu_download "$name" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
sudo su -c "chown -v -R root:root /usr/share/emacs/$version &&
rm -vf /usr/lib/systemd/user/emacs.service"
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
