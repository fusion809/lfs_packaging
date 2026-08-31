#!/bin/bash
# gitlab.freedesktop.org version fetcher
function gfd_ver {
	local repo=$1
	local name=$(echo $repo | cut -d '/' -f 2 | tr '[:upper:]' '[:lower:]')
	local up_ver=$(fdt_ver $repo)
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" && return

	local git_ver=$(gfl_ver $repo)
	ver_check "$git_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return

	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}

function spice_ver {
	local name=$1
	if [[ "$name" == "spice-vdagent" ]]; then
		local repo="spice/linux/vd_agent"
	else
		local repo="spice/$name"
	fi
	local up_ver=$(wsp_ver $repo)
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(gsp_ver $repo)
	ver_check "$git_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	fver "$name" "$inst_ver"
}

function way_ver {
    local name=$1
	local inst_ver=$(pkgver $name)
    local up_ver=$(wget -T 2 -cqO- https://wayland.freedesktop.org/releases.html | grep "$name-[0-9].*.tar.xz" | grep -v ".9[0-9].tar.xz" | head -n 1 | cut -d '/' -f 8)
    ver_check "$up_ver" "$inst_ver" && return

    local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/wayland/$name.git | grep "refs/tags/[0-9.]*$" | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}

# xorg.freedesktop.org version fetcher
function xfd_ver() {
	name="$1"
	if echo $name | grep "lib" &> /dev/null || [[ "$name" == "xtrans" ]]; then
		type="lib"
	elif echo $name | grep "xf86" &> /dev/null; then
		type="driver"
	else
		type="app"
	fi
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

	local arch_ver=$(aver $name)
	if ! [[ "$arch_ver" =~ ^[0-9.]+$ ]]; then
		local arch_ver=$(aver xorg-$name)
	fi
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(wget -T 2 -t 1 -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/x/x7$type.html | grep -E "$name-[0-9.]+" | sed 's/^.*\s//g' | cut -d '-' -f 2 | sed 's/.tar.xz//g')
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
