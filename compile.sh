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
	mkdir build
	cd build
	CFLAGS="-O2 -fPIC"
	CXXFLAGS="-O2 -fPIC"
	meson setup "$@" ..
	ninja -j$(nproc)
	sudo ninja install
}