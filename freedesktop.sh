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
	local up_ver=$(fdt_ver $repo $name)
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" && return

	local git_ver=$(gfl_ver $repo $name)
	ver_check "$git_ver" "$inst_ver" && return

	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return

	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}

function spice_ver {
	local name=$1
	local repo=$(spice_repo $name)
	local up_ver=$(wsp_ver $repo)
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(gsp_ver $repo)
	ver_check "$git_ver" "$inst_ver" && return

	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	fver "$name" "$inst_ver"
}

function way_ver {
    local name=$1
	local inst_ver=$(pkgver $name)
    local up_ver=$(wget -T 5 -cqO- https://wayland.freedesktop.org/releases.html | grep "$name-[0-9].*.tar.xz" | grep -v ".9[0-9].tar.xz" | head -n 1 | cut -d '/' -f 8)
    ver_check "$up_ver" "$inst_ver" && return

    local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/wayland/$name.git | grep "refs/tags/[0-9.]*$" | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return

    local vat_ver=$(vatver $name)
    ver_check "$vat_ver" "$inst_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
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
	local type=$(get_xfd_type $name)
	local up_ver=$(wxfd_ver $type $name)
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" && return

	if [[ "$name" == "libXfont2" ]]; then
		local git_ver=$(gxfd_ver $type "libXfont")
	elif [[ "$name" == "xtrans" ]]; then
		local git_ver=$(gxfd_ver $type "libxtrans")
	else
		local git_ver=$(gxfd_ver $type $name)
	fi
	ver_check "$git_ver" "$inst_ver" && return

	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	if ! [[ "$arch_ver" =~ ^[0-9.]+$ ]]; then
		local arch_ver=$(aver xorg-$name)
	fi
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(wget -T 5 -t 1 -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/x/x7$type.html | grep -E "$name-[0-9.]+" | sed 's/^.*\s//g' | cut -d '-' -f 2 | sed 's/.tar.xz//g')
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}

function xcb_ver {
	local name=$1
	local inst_ver=$(pkgver $name)
	local up_ver=$(wxcb_ver $name)
	ver_check "$up_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}

