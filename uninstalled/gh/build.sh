#!/bin/bash
set -e
name=gh
repo=cli/cli
version=$(gh_ver $repo)
filename="${name}_${version}_linux_amd64.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/cli/cli/releases/download/v$version/$filename
fi
unpk_enter "$filename" "$direname"
sudo cp -r bin/* /usr/bin/
sudo cp -r share/man/man1/* /usr/share/man/man1
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
