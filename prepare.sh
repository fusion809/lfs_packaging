#!/bin/bash
function strip_file_ext {
    case $1 in
        *.tar.*)
            printf '%s\n' "$(echo $1 | sed -E 's/\.tar.[a-z0-9]+//g')"
            ;;
        *.tar)
            printf '%s\n' "${1%.tar}"
            ;;
        *.tgz)
            printf '%s\n' "${1%.tgz}"
            ;;
        *.zip)
            printf '%s\n' "${1%.zip}"
            ;;
        *.gz)
            printf '%s\n' "${1%.gz}"
            ;;
        *.lz)
            printf '%s\n' "${1%.lz}"
            ;;
        *.lzma)
            printf '%s\n' "${1%.lzma}"
            ;;
        *.bz2)
            printf '%s\n' "${1%.bz2}"
            ;;
        *.xz)
            printf '%s\n' "${1%.xz}"
            ;;
        *.zst)
            printf '%s\n' "${1%.zst}"
            ;;
        *)
            printf '%s\n' "$1"
            ;;
    esac
}

function file_ext {
    case $1 in
        *.tar.*)
            printf '%s\n' "$(echo $1 | sed -E 's/.*.(tar\.[a-z0-9]+)/\1/g')"
            ;;
        *.tar)
            printf '%s\n' "tar"
            ;;
        *.tgz)
            printf '%s\n' "tgz"
            ;;
        *.zip)
            printf '%s\n' "zip"
            ;;
        *.gz)
            printf '%s\n' "gz"
            ;;
        *.lz)
            printf '%s\n' "lz"
            ;;
        *.lzma)
            printf '%s\n' "lzma"
            ;;
        *.bz2)
            printf '%s\n' "bz2"
            ;;
        *.xz)
            printf '%s\n' "xz"
            ;;
        *.zst)
            printf '%s\n' "zst"
            ;;
        *)
            printf '%s\n' "$1"
            ;;
    esac
}

function unpk_enter {
	if ! [[ -d $1/.git ]] && ( ( echo $1 | grep "\.[gtlbx]" &> /dev/null ) || ( echo $1 | grep "\.zstd" &> /dev/null ) ); then
    		local filename=$1
   		if [[ -n $2 ]]; then
        		local direname=$2
		    else
        		local direname=$(strip_file_ext $filename)
		fi
	    	sudo rm -rf $direname
	    	case $(file_ext $filename) in
			tar.*|tgz) tar xf $filename ;;
			gz) gunzip $filename ;;
			lz) lzip -d $filename ;;
			lzma) lzma -d $filename ;;
			bz2) bunzip2 $filename ;;
			xz) xz -d $filename ;;
			zst) zstd -d $filename ;;
			*)
				printf '%s\n' "Didn't decompress $filename"
				;;
		esac
    		cd $direname
	elif (echo $1 | grep "\.zip" &> /dev/null) ; then
    		local filename=$1
   		if [[ -n $2 ]]; then
        		local direname=$2
		    else
        		local direname=$(strip_file_ext $filename)
		fi
	    	sudo rm -rf $direname
		mkdir "$direname"
		unzip ../"$filename"
    	else
		local name=$1
		local version=$2
		cd $name && git checkout v$version
	fi
}
