#!/bin/bash
function wperl_ver {
    local code=$1
	local twocode="${1:0:2}"
	local onecode="${1:0:1}"
    local _name=$2
    local url="https://www.cpan.org/authors/id/$onecode/$twocode/$code"
    wget -cqO- -T 5 -t 1 "$url" | grep "$_name-[0-9]+\.[0-9]+" -oE \
    | cut -d '-' -f 2 | sort -V | tail -n 1
}