#!/bin/bash
name=vscode
version=$(git ls-remote --tags https://github.com/microsoft/vscode.git | grep -oP 'refs/tags/\K[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)
filename="code_${version}_amd64.deb"
if ! [[ -f $filename ]]; then
	wget -c https://update.code.visualstudio.com/${version}/linux-deb-x64/stable -O "$filename"
fi

mkdir -p $name
cd $name
bsdtar xf ../"$filename"
tar xf data.tar.xz
cd usr/share
sudo rm -rf /usr/share/code
sudo cp -r code /usr/share/
sudo cp -r appdata/code.appdata.xml /usr/share/appdata
sudo cp -r applications/code*.desktop /usr/share/applications
sudo cp -r pixmaps/*.png /usr/share/pixmaps
sudo cp -r bash-completion/completions/code /usr/share/bash-completion/completions
sudo cp -r mime/packages/code-workspace.xml /usr/share/mime/packages/
sudo mkdir -p /usr/share/zsh/vendor-completions
sudo cp -r zsh/vendor-completions/_code /usr/share/zsh/vendor-completions
sudo ln -sf /usr/share/code/bin/code /usr/bin/
echo $version > /var/lib/custom-packages/$name
cd ../../..
rm -rf $name $filename
