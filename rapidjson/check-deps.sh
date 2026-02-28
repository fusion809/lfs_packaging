#!/bin/bash

if ! which wget &> /dev/null; then
	echo "wget not found and used for downloading sources"
	exit
fi

if ! which cmake &> /dev/null; then
	echo "cmake not found and used for compiling"
	exit
fi

if ! which patch &> /dev/null; then
	echo "patch not found and used as part of the build process."
	exit
fi

if ! which make &> /dev/null; then
	echo "make not found and used as part of the build process."
	exit
fi