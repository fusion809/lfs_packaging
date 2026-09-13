#!/bin/bash
set -e
name=cracklib
repo=$name/$name
version=$(gh_ver $repo)
depends=(glibc zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/v$version/$filename
fi
word_filename="$name-words-$version.xz"
if ! [[ -f $word_filename ]]; then
	wget -c --progress=bar:force https://github.com/cracklib/cracklib/releases/download/v$version/$word_filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr    \
            --disable-static \
	    --with-default-dict=/usr/lib/cracklib/pw_dict)
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
