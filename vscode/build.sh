#!/bin/bash
name=vscode
version=$(wget -cqO- https://github.com/Microsoft/vscode/releases | grep "releases/tag" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)
filename="code_${version}_amd64.deb"
if ! [[ -f $filename ]]; then
	wget -c https://update.code.visualstudio.com/${version}/linux-deb-x64/stable -O "$filename"
fi

mkdir -p $name
cd $name
bsdtar xf ../"$filename"
tar xf data.tar.xz
cd usr/share
sudo cp -r code /usr/share/
sudo cp -r appdata/code.appdata.xml /usr/share/appdata
sudo cp -r applications/code*.desktop /usr/share/applications
sudo cp -r pixmaps/*.png /usr/share/pixmaps
sudo cp -r bash-completion/completions/code /usr/share/bash-completion/completions
sudo cp -r mime/packages/code-workspace.xml /usr/share/mime/packages/
sudo mkdir -p /usr/share/zsh/vendor-completions
sudo cp -r zsh/vendor-completions/_code /usr/share/zsh/vendor-completions
echo $version > /var/lib/custom-packages/$name
rm -rf $name $filename
