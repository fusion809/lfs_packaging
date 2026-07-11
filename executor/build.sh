#!/bin/bash
name=executor
version=$(wget -cqO- https://raw.githubusercontent.com/fusion809/executor-raujonas.github.io/refs/heads/master/metadata.json | grep '"version"' | sed 's/.*://g')
lfs_depends=(wget)
blfs_depends=(gnome-shell gnome-shell-extensions glib2 git)

if ! [[ -d /usr/share/gnome-shell/extensions/executor-raujonas.github.ip ]]; then
	sudo git -C /usr/share/gnome-shell/extensions clone https://github.com/fusion809/executor-raujonas.github.io executor@raujonas.github.io
fi
sudo glib-compile-schemas /usr/share/gnome-shell/extensions/executor@raujonas.github.io/schemas
echo "$version" > /var/lib/custom-packages/$name
