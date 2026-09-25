#!/bin/bash
function ngnu_ver {
	local name=$1
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wngnu_ver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(gngnu_ver $name)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

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
	wget -c --progress=bar:force https://download.savannah.nongnu.org/releases/$name/$filename ||get_ngnu_git $name 
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
