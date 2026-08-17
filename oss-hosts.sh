#!/bin/bash

# codeberg version fetcher
function cb_ver {
	local repo=$1
	local name=$(echo $repo | cut -d '/' -f 2)
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- https://codeberg.org/$repo/tags | grep "/tag/" | head -n 1 | cut -d '"' -f 4 | cut -d '/' -f 6)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(git ls-remote --tags https://codeberg.org/$repo.git | grep -v "\^{}" | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	echo $inst_ver
}

# github version fetcher
function gh_ver {
	if [[ -n "$2" ]]; then
		name="$2"
	else
		name=$(echo $1 | cut -d '/' -f 2)
	fi
	local inst_ver=$(pkgver $name)
	local up_ver=$(ght_ver $1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(ghl_ver $1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	echo $inst_ver
}

# GNU version fetcher
function gnu_ver {
	local name=$1
	local inst_ver=$(pkgver $name)
	local up_ver=$(wgnu_ver $name)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(ggnu_ver $name)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	echo $inst_ver
}

# SourceForge version fetcher
function sf_ver {
	local name=$1
    local inst_ver=$(pkgver $name)
    local up_ver=$(wsf_ver $name)
	ver_check "$up_ver" "$inst_ver" && return
    local git_ver=$(gsf_ver $name)
	ver_check "$git_ver" "$inst_ver" && return
	local name=$(echo $1 | cut -d '/' -f 1)
    local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	echo "$inst_ver"
}