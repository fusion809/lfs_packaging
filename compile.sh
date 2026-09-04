#!/bin/bash

function maki {
    if [[ "$1" == "html" ]]; then
        make -j$(nproc)
        make -j$(nproc) html
        sudo make install
    else
        make "$@" -j$(nproc)
        sudo make "$@" install
    fi
}

function cmaki {
	cmake -S . -B build "$@"
	cd build
	generator=
for arg in "$@"; do
    if [[ "$generator" == "-G" ]]; then
        if [[ "$arg" == "Ninja" ]]; then
            generator="Ninja"
        else
            generator=
        fi
    elif [[ "$arg" == "-G" ]]; then
        generator="-G"
    fi
done

if [[ "$generator" == "Ninja" ]]; then
    ninja -j$(nproc)
    sudo ninja install
else
    maki
fi
}

function cmi {
    local configure_args=()
    local html=false

    for arg in "$@"; do
        if [[ "$arg" == "html" ]]; then
            html=true
        else
            configure_args+=("$arg")
        fi
    done

    if [[ -f "configure" ]] ; then
    	./configure "${configure_args[@]}"
    elif [[ -f "autogen.sh" ]]; then
	    sudo ./autogen.sh "${configure_args[@]}"
	    sudo chown $USER . -R
	    ./configure "${configure_args[@]}"
    elif [[ -f "bootstrap" ]]; then
	sudo ./bootstrap
	    sudo chown $USER . -R
	./configure "${configure_args[@]}"
    else
	    echo "configure and autogen.sh scripts not found" && exit 1
    fi

    if $html; then
        make -j$(nproc)
        make -j$(nproc) html
        sudo make install
    else
        maki
    fi
}

function mni {
	export CFLAGS="-O2 -fPIC"
	export CXXFLAGS="-O2 -fPIC"
	source_dir=..

	meson_args=("$@")
source_dir=..

if ((${#meson_args[@]})); then
    last_arg=
    meson_options=()

    for arg in "${meson_args[@]}"; do
        if [[ -n "$last_arg" ]]; then
            meson_options+=("$last_arg")
        fi
        last_arg="$arg"
    done

    if [[ -d "$last_arg" ]]; then
        source_dir="$last_arg"
        meson_args=("${meson_options[@]}")
    fi
fi
echo "source_dir=$source_dir"
	if ( echo $PWD | grep "build" &> /dev/null ) && ( echo $source_dir | grep "gobject-introspection" &>/dev/null ); then
		echo "Option 1 build, should be gobject-introspection"
		meson setup "$source_dir" gi-build "${meson_args[@]}" || exit 1
		ninja -C gi-build -j$(nproc)
		sudo ninja -C gi-build install
		return 0;
	elif ! ( echo $PWD | grep "build" &> /dev/null ); then
		echo "Optional 2 build, should be generally applicable"
		mkdir build
		cd build
		meson setup "${meson_args[@]}" "$source_dir" || exit 1
		docbookver=$(head -n 1 /var/lib/book-packages/docbook-xsl-nons)
		files=()

		while IFS= read -r -d '' file; do
			files+=("$file")
		done < <(find . -type f \( -name build.ninja -o -name intro-targets.json \) -print0)

		if [[ -f ../docs/reference/gtk/meson.build ]]; then
			files+=(../docs/reference/gtk/meson.build)
		fi

		if ((${#files[@]})); then
			sed -i "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-$docbookver/manpages/docbook.xsl|g" "${files[@]}"
		fi
	elif [[ -f build.ninja ]]; then
		echo "Option 3 build"
		echo "${meson_args[@]}"
		meson configure "${meson_args[@]}" || exit 1
	fi
	ninja -j$(nproc)
	sudo ninja install

}

function pfile {
    wget -cqO- \
        "https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/$1.html" \
        "https://www.linuxfromscratch.org/blfs/view/systemd/postlfs/$1.html" |
    grep '\.patch' |
    cut -d '/' -f 2 |
    grep -oE '[^[:space:]<"]+\.patch' |
    grep -v '^[[:space:]]*$'
}

function gap_patches {
    local patches

    patches=$(pfile "$1" | grep -v '^[[:space:]]*$')

    if [[ -z "$patches" ]]; then
        echo "No patches found."
        return
    fi

    while IFS= read -r i; do
        echo "Getting and applying $i"

        wget -c "https://www.linuxfromscratch.org/patches/lfs/development/$i" ||
        wget -c "https://www.linuxfromscratch.org/patches/blfs/svn/$i"

        patch -Np1 -i "$i"
    done <<< "$patches"
}
