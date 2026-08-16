#!/bin/bash
source ~/lfs_packaging/base-version.sh
source ~/lfs_packaging/version-checks.sh
source ~/lfs_packaging/freedesktop.sh
source ~/lfs_packaging/gnome.sh
source ~/lfs_packaging/add_deps.sh

# codeberg version fetcher
function cb_ver {
	local repo=$1
	local name=$(echo $repo | cut -d '/' -f 2)
	local up_ver=$(wget -cqO- https://codeberg.org/$repo/tags | grep "/tag/" | head -n 1 | cut -d '"' -f 4 | cut -d '/' -f 6)
	ver_check "$up_ver" "$name" && return
	local git_ver=$(git ls-remote --tags https://codeberg.org/$repo.git | grep -v "\^{}" | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$git_ver" "$name" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$name" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$name" && return
}

function cmi {
	./configure $@
	make -j$(nproc)
	sudo make install
}

# github version fetcher
function gh_ver {
	local up_ver=$(ght_ver $1)
	ver_check "$up_ver" && return

	local git_ver=$(ghl_ver $1)
	ver_check "$git_ver" && return

	if [[ -n "$2" ]]; then
		name="$2"
	else
		name=$(echo $1 | cut -d '/' -f 2)
	fi
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$name" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$name" && return
}

# GNU version fetcher
function gnu_ver {
	local name=$1
	local up_ver=$(wgnu_ver $name)
	ver_check "$up_ver" && return
	local git_ver=$(ggnu_ver $name)
	ver_check "$git_ver" "$name" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$name" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$name" && return
}

function mni {
	mkdir build
	cd build
	CFLAGS="-O2 -fPIC"
	CXXFLAGS="-O2 -fPIC"
	meson setup "$@" ..
	ninja -j$(nproc)
	sudo ninja install
}
# SourceForge version fetcher
function sf_ver {
	local name=$1
    local up_ver=$(wsf_ver $name)
	ver_check "$up_ver" "$name" && return
    local git_ver=$(gsf_ver $name)
	ver_check "$git_ver" "$name" && return
	local name=$(echo $1 | cut -d '/' -f 1)
    local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$name" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$name" && return
}