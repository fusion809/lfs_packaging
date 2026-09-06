#!/bin/bash
while read -r line; do

    # Get the file name, ignoring comments and blank lines
    if $(echo $line | grep -E -q '^ *$|^#' ); then continue; fi
    file=$(echo $line | cut -d" " -f2)

    pkg=$(       echo $file|sed 's|^.*/||')    # Remove directory
    name=$(      echo $pkg |sed 's|-6.*$||')   # Isolate package name
    source add_deps.sh
    cp -r attica $name
    sed -i -e "s|attica|$name|g" $name/build.sh
    mv /var/lib/book-packages/$name /var/lib/custom-packages/$name
    add_deps $name

done < frameworks-6.29.0.md5

exit
