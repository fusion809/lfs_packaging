#!/bin/bash
set -e
NAME=antigravity
baseurl="https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/dists/antigravity-debian/main/binary-amd64/Packages"
depends=()
lfs_depends=(bash coreutils glibc sed tar)
blfs_depends=(libarchive libx11 libxkbfile wget)
# jq is listed as a make dependency for the AUR package, but it's not required to build this package nor run it.
filename=$(wget -cqO- $baseurl | grep deb | tail -n 1 | sed 's|Filename: pool/antigravity-debian/||g')
VERSION=$(echo $filename | grep -v "beta\|alpha\|rc" | cut -d '_' -f 2 | cut -d '-' -f 1)
_STR=$(echo $filename | sed 's|antigravity_1.19.6-||g' | sed 's/.deb//g')

if ! [[ -f $filename ]]; then
	wget -c https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/pool/antigravity-debian/$filename
fi
sudo rm -rf $NAME
mkdir $NAME
cd $NAME
bsdtar xf ../$filename
tar xf data.tar.xz
cd usr/share
sudo cp -r antigravity /usr/share
sudo cp applications/$NAME*.desktop /usr/share/applications/
sudo cp bash-completion/completions/$NAME /usr/share/bash-completion/completions
sudo cp zsh/vendor-completions/_$NAME /usr/share/zsh/site-functions
sudo cp mime/packages/$NAME-workspace.xml /usr/share/mime/packages
sudo cp pixmaps/$NAME.png /usr/share/pixmaps
cd ..
sudo rm -rf $NAME
echo $VERSION > /var/lib/lfs-custom-packages/$NAME