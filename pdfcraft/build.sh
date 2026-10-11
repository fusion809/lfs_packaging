#!/bin/bash
set -e
name=pdfcraft
repo=storytold/$name
description="An open-source, clean-room reimplementation of Adobe Acrobat built in pure Rust."
homepage="https://getartcraft.com/apps/pdfcraft"
version=$(gh_ver $repo)
depends=(gcc glibc)
craft_buildin $name $version
