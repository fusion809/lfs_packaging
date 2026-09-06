#!/bin/bash
while read -r line; do

    # Get the file name, ignoring comments and blank lines
    if $(echo $line | grep -E -q '^ *$|^#' ); then continue; fi
    file=$(echo $line | cut -d" " -f2)

    pkg=$(       echo $file|sed 's|^.*/||')    # Remove directory
    name=$(      echo $pkg |sed 's|-6.*$||')   # Isolate package name
    if ! [[ -f /var/lib/book-packages/$name ]]; then
	    continue
    fi
    source add_deps.sh
    cp -r kdecoration $name
    sed -i -e "s|kdecoration|$name|g" $name/build.sh
    mv /var/lib/book-packages/$name /var/lib/custom-packages/$name
    add_deps $name

done < plasma-6.7.4.md5

exit
