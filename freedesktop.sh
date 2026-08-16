#!/bin/bash
# gitlab.freedesktop.org version fetcher
function gfd_ver {
	local repo=$1
	local name=$(echo $repo | cut -d '/' -f 2 | tr '[:upper:]' '[:lower:]')
	local up_ver=$(fdt_ver $repo)
	ver_check "$up_ver" && return

	local git_ver=$(gfl_ver $repo)
	ver_check "$git_ver" "$name" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$name" && return

	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$name" && return
}

function spice_ver {
	local name=$1
	if [[ "$name" == "spice-vdagent" ]]; then
		local repo="spice/linux/vd_agent"
	else
		local repo="spice/$name"
	fi
	local up_ver=$(wget --timeout=5 -cqO- "https://gitlab.freedesktop.org/api/v4/projects/$repo/releases?per_page=1" | grep -o '"tag_name":"[^"]*"' | grep -v "server" | head -n 1 | cut -d'"' -f4 | sed 's/^v//')
	ver_check "$up_ver" && return
	local git_ver=$(git ls-remote --tags --refs https://gitlab.com/$repo.git | cut -d '/' -f 3 | grep "[0-9]" | grep -v "server\|common\|client" | sed 's/^v//g' | sed 's|spice-vdagent-||g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$name" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$name" && return
}

function way_ver {
    local name=$1
    local up_ver=$(wget -T 5 -cqO- https://wayland.freedesktop.org/releases.html | grep "$name-[0-9].*.tar.xz" | grep -v ".9[0-9].tar.xz" | head -n 1 | cut -d '/' -f 8)
    ver_check "$up_ver" && return

    local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/wayland/$name.git | grep "refs/tags/[0-9.]*$" | cut -d '/' -f 3 | sort -V | tail -n 1)
    ver_check "$git_ver" "$name" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" "$name" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$name" && return
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
	ver_check "$up_ver" && return

	local git_ver=$(gxfd_ver $type $name)
	ver_check "$git_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$name" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$name" && return
}
