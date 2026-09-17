#!/bin/bash
function spice_repo {
	local name=$1
	if [[ "$name" == "spice-vdagent" ]]; then
		local repo="spice/linux/vd_agent"
	else
		local repo="spice/$name"
	fi
	echo $repo
}
