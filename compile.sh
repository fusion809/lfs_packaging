#!/bin/bash

function maki {
	make "$@" -j$(nproc)
	sudo make "$@" install
}

function cmaki {
	cmake -S . -B build "$@"
	cd build
	maki
}

function cmi {
	./configure $@
	maki
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
		meson setup "$source_dir" gi-build "${meson_args[@]}" || exit 1
		ninja -C gi-build -j$(nproc)
		sudo ninja -C gi-build install
		return 0;
	elif ! ( echo $PWD | grep "build" &> /dev/null ); then
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
		echo "${meson_args[@]}"
		meson configure "${meson_args[@]}" || exit 1
	fi
	ninja -j$(nproc)
	sudo ninja install

}