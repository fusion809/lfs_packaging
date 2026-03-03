#!/bin/bash
set -e
name=antigravity
baseurl="https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/dists/antigravity-debian/main/binary-amd64/Packages"
downurl="https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/pool/antigravity-debian/"
depends=()
lfs_depends=(bash coreutils glibc sed tar)
blfs_depends=(libarchive 
libx11 libxkbfile # Xorg libraries
wget)
filename=$(wget -cqO- $baseurl | grep deb | tail -n 1 | sed 's|File_name: pool/antigravity-debian/||g')
version=$(echo $filename | grep -v "beta\|alpha\|rc" | cut -d '_' -f 2 | cut -d '-' -f 1)
_STR=$(echo $filename | sed 's|antigravity_1.19.6-||g' | sed 's/.deb//g')

if ! [[ -f $filename ]]; then
	wget -c $downurl/$filename
fi
sudo rm -rf $name
mkdir $name
cd $name
bsdtar xf ../$filename
tar xf data.tar.xz
cd usr/share
sudo cp -r antigravity /usr/share
sudo cp applications/$name*.desktop /usr/share/applications/
sudo cp bash-completion/completions/$name /usr/share/bash-completion/completions
sudo cp zsh/vendor-completions/_$name /usr/share/zsh/site-functions
sudo cp mime/packages/$name-workspace.xml /usr/share/mime/packages
sudo cp pixmaps/$name.png /usr/share/pixmaps
cd ..
sudo rm -rf $name
echo $version > /var/lib/lfs-custom-packages/$name