#!/bin/bash
function bb_ver {
	local repo=$1
	if ! [[ -n $2 ]]; then
		local name=$(echo $repo | cut -d '/' -f 2)
	else
		local name=$2
	fi
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver $name)
	local git_ver=$(gbb_ver $repo $name)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

# codeberg version fetcher
function cb_ver {
	local repo=$1
	if ! [[ -n $2 ]]; then
		local name=$(echo $repo | cut -d '/' -f 2)
	else
		local name=$2
	fi
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- https://codeberg.org/$repo/tags | grep -oE "/tag/[v]*[0-9.]+" | sed 's|/tag/[v]*||g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(git ls-remote --tags https://codeberg.org/$repo.git | grep "[v]*[0-9.]+" -E | grep -v "\^{}" | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

function perl_ver {
	local name=$1
	local _name=$2
	local code=$3
	local twocode="${3:0:2}"
	local onecode="${3:0:1}"
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://www.cpan.org/authors/id/$onecode/$twocode/$code | grep "$_name-[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

function sd_ver {
	local repo=$1
	if [[ -n $2 ]]; then
		local name=$2
	else
		local name=$(echo $1 | cut -d '/' -f 2)
	fi
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://salsa.debian.org/$repo/-/tags | grep "[v]*[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/^v//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://salsa.debian.org/$repo.git | grep "[v]*[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/^v//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
    local vat_ver=$(vatver $name)
    ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
    local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
