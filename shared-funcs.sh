#!/bin/bash
source ~/lfs_packaging/base-version.sh
source ~/lfs_packaging/version-checks.sh
source ~/lfs_packaging/freedesktop.sh
source ~/lfs_packaging/gnome.sh
source ~/lfs_packaging/oss-hosts.sh
source ~/lfs_packaging/add_deps.sh
source ~/lfs_packaging/compile.sh
function get_ngnu_git {
	local name=$1
	if [[ "$name" == "libpipeline" ]]; then
		git_url="https://gitlab.com/libpipeline/libpipeline.git"
	else
		git_url="https://git.savannah.nongnu.org/git/$name.git"
	fi
	git clone $git_url
}
function get_ngnu {
	local filename=$1
	local direname=$2
	local name=$3
	local version=$4
	if ! [[ -f $filename ]] && ! [[ -d $name ]] ; then
	wget -c https://download.savannah.nongnu.org/releases/$name/$filename ||get_ngnu_git $name 
	fi
if [[ -f $filename ]]; then
	rm -rf $direname && tar xf $filename && cd $direname
elif [[ -d $name ]]; then
	cd $name
	if git tag | grep "v$version" &>/dev/null; then
		git checkout v$version
	else
		git checkout $version
	fi
fi
}
