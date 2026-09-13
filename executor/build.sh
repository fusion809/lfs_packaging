#!/bin/bash
set -e
name=executor
version=$(wget -cqO- https://raw.githubusercontent.com/fusion809/executor-raujonas.github.io/refs/heads/master/metadata.json | grep '"version"' | sed 's/.*://g')
lfs_depends=(wget)
blfs_depends=(gnome-shell gnome-shell-extensions glib2 git)

if ! [[ -d /usr/share/gnome-shell/extensions/executor@raujonas.github.io ]]; then
	sudo git -C /usr/share/gnome-shell/extensions clone https://github.com/fusion809/executor-raujonas.github.io executor@raujonas.github.io
else
	sudo git -C /usr/share/gnome-shell/extensions/executor@raujonas.github.io pull origin master
fi
sudo chmod 777 -R /usr/share/gnome-shell/extensions/executor@raujonas.github.io
glib-compile-schemas /usr/share/gnome-shell/extensions/executor@raujonas.github.io/schemas
dconf load /org/gnome/shell/extensions/executor/ < /usr/share/gnome-shell/extensions/executor@raujonas.github.io/executor-settings.dconf
echo "$version" | sudo tee /var/lib/custom-packages/$name
