#!/bin/bash
function gsd_ver {
    timeout 5 git ls-remote --tags --refs https://salsa.debian.org/$1.git  \
    | grep "[v]*[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/^v//g' | sort -V \
    | tail -n 1
}

function wsd_ver {
    wget -T 5 -t 1 -cqO- "https://salsa.debian.org/$1/-/tags" \
    | grep "[v]*[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/^v//g' | sort -V \
    | tail -n 1
}