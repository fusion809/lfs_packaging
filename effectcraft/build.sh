#!/bin/bash
set -e
name=effectcraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Adobe After Effects."
homepage="https://getartcraft.com/apps/effectcraft"
version=$(gh_ver $repo)
depends=(alsa-lib gcc glibc)
craft_buildin $name $version

