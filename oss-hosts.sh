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
	local up_ver=$(wget -cqO- https://codeberg.org/$repo/tags | grep "/tag/" | head -n 1 | cut -d '"' -f 4 | cut -d '/' -f 6)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(git ls-remote --tags https://codeberg.org/$repo.git | grep -v "\^{}" | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

# github version fetcher
function gh_ver {
	if [[ -n "$2" ]]; then
		name="$2"
	else
		name=$(echo $1 | cut -d '/' -f 2)
	fi
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver $name)
	local up_ver=$(ght_ver $1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(ghl_ver $1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

# github version fetcher
function gl_ver {
	if [[ -n "$2" ]]; then
		name="$2"
	else
		name=$(echo $1 | cut -d '/' -f 2)
	fi
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver $name)
	local up_ver=$(glt_ver $1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(gll_ver $1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

# GNU version fetcher
function gnu_ver {
	local name=$1
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver $name)
	local up_ver=$(wgnu_ver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(ggnu_ver $name)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

function kap_ver {
	local name=$1
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver $name)
	local up_ver=$(wkap_ver)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(gkap_ver $name)	
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

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
    	local vat_ver=$(vatver $name)
    	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
    	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

# SourceForge version fetcher
function sf_ver {
	local repo=$1
	local name=$(echo $repo | cut -d '/' -f 1)
	local lfs_vers=$(lfs_ver $name)
    	local inst_ver=$(pkgver $name)
    	local up_ver=$(wsf_ver $repo)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
    	local git_ver=$(gsf_ver $repo)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
    	local vat_ver=$(vatver $name)
    	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
    	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

function sw_ver {
	local name=$1
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
    	local up_ver=$(wsw_ver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(gsw_ver $name)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
    	local vat_ver=$(vatver $name)
    	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
    	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
