#!/bin/bash
function gcb_ver {
    local url="https://codeberg.org/$1.git"
    timeout 5 git ls-remote --tags --refs "$url" | grep "tags/[v]*[0-9.]+" -oE \
    | sed 's|.*tags/[v]*||g' | sort -V | tail -n 1
}

function wcb_ver {
    local url="https://codeberg.org/$1/tags"
    wget -T 5 -t 1 -cqO- "$url" | grep -oE "/tag/[v]*[0-9.]+" \
    | sed 's|/tag/[v]*||g' | sort -V | tail -n 1
}