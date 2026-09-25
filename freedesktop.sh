#!/bin/bash
# gitlab.freedesktop.org version fetcher
function gfd_ver {
	local repo=$1
	if [[ -n "$2" ]]; then
		local name=$2
	else
		local name=$(echo $repo | cut -d '/' -f 2 | tr '[:upper:]' '[:lower:]')
		local namef=$(echo $repo | cut -d '/' -f 1 | tr '[:upper:]' '[:lower:]')
		local name2=$(echo "${namef}-${name/x/}")
		if ! [[ -f $LFP/$name/build.sh ]] && [[ -f $LFP/$name2/build.sh ]]; then
			name="$name2"
		fi
	fi
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(fdt_ver $repo $name)
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(gfl_ver $repo $name)
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

function spice_ver {
	local name=$1
	local repo=$(spice_repo $name)
	local art_vers=$(artver $name)
	local up_ver=$(wsp_ver $repo)
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" "$art_vers" && return
	local git_ver=$(gsp_ver $repo)
	ver_check "$git_ver" "$inst_ver" "$art_ver" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$art_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$art_ver" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

function way_ver {
    local name=$1
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
    local up_ver=$(wget -T 5 -cqO- https://wayland.freedesktop.org/releases.html | grep "$name-[0-9].*.tar.xz" | grep -v ".9[0-9].tar.xz" | head -n 1 | cut -d '/' -f 8)
    ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
    local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/wayland/$name.git | grep "refs/tags/[0-9.]*$" | cut -d '/' -f 3 | sort -V | tail -n 1)
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

function get_xfd_type {
	local name=$1
	local type="";
	if echo $name | grep "^lib" &> /dev/null || [[ "$name" == "xtrans" ]] || echo $name | grep "xcb-util-" &> /dev/null; then
		type+="lib"
	elif echo $name | grep "xf86\|driver" &> /dev/null; then
		type+="driver"
	elif echo $name | grep "proto" &> /dev/null; then
		type+="proto"
	elif [[ "$name" == "util-macros" ]]; then
		type="util"
	else
		type+="app"
	fi
	echo "$type"
}
# xorg.freedesktop.org version fetcher
function xfd_ver() {
	local name="$1"
	local lfs_vers=$(lfs_ver $name)
	local type=$(get_xfd_type $name)
	local lfs_vers=$(cat $HOME/.cache/blfs-x7$type.html | grep -oE "$name-[0-9.]+" |  sed 's/\.$//g' | sed "s/$name-//g" | uniq)
	local up_ver=$(wxfd_ver $type $name)
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

	if [[ "$name" == "libXfont2" ]]; then
		local git_ver=$(gxfd_ver $type "libXfont")
	elif [[ "$name" == "xtrans" ]]; then
		local git_ver=$(gxfd_ver $type "libxtrans")
	else
		local git_ver=$(gxfd_ver $type $name)
	fi
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	if ! [[ "$arch_ver" =~ ^[0-9.]+$ ]]; then
		local arch_ver=$(aver xorg-$name)
	fi
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	if ! [[ "$art_ver" =~ ^[0-9.]+$ ]]; then
		local art_ver=$(artver xorg-$name)
	fi
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}

function xcb_ver {
	local name=$1
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wxcb_ver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
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

