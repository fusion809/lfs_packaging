#!/bin/bash
function gcb_ver {
    timeout 5 git ls-remote --tags https://codeberg.org/$1.git | grep "[v]*[0-9.]+" -E | grep -v "\^{}" | cut -d '/' -f 3 | sort -V | tail -n 1
}

function wcb_ver {
    wget -T 5 -t 1 -cqO- https://codeberg.org/$1/tags | grep -oE "/tag/[v]*[0-9.]+" | sed 's|/tag/[v]*||g' | sort -V | tail -n 1
}