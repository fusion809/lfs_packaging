#!/bin/bash
name=make-ca
version=$(gh_ver "lfs-book/make-ca")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"

if ! [[ -f "$filename" ]]; then
	wget -c https://github.com/lfs-book/make-ca/archive/refs/tags/v$version.tar.gz -O "$filename"
fi

tar xf "$filename"
cd "$direname"
sed '/mktemp/s/-t //' -i make-ca
sudo make install
sudo install -vdm755 /etc/ssl/local
sudo /usr/sbin/make-ca -g --force
sudo systemctl enable update-pki.timer
cd ..
rm -rf "$filename" "$direname"
echo "$version" > /var/lib/custom-packages/$name
