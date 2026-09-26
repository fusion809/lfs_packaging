#!/bin/bash
set -e
name=cracklib
homepage="https://github.com/cracklib/cracklib"
description="Password Checking Library"
repo=$name/$name
version=$(gh_ver $repo)
depends=(glibc zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
word_filename="$name-words-$version.xz"
ghr_download "$repo" "v$version" "$word_filename"
unpk_enter "$filename" "$direname"
options=(
    --prefix=/usr    \
    --disable-static \
	--with-default-dict=/usr/lib/cracklib/pw_dict
)
cmi "${options[@]}"
sudo su -c "xzcat ../cracklib-words-$version.xz \
                       > /usr/share/dict/cracklib-words       &&
ln -v -sf cracklib-words /usr/share/dict/words                &&
echo $(hostname) >>      /usr/share/dict/cracklib-extra-words &&
install -v -m755 -d      /usr/lib/cracklib                    &&

create-cracklib-dict     /usr/share/dict/cracklib-words \
                         /usr/share/dict/cracklib-extra-words"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
