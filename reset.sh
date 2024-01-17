#!/usr/bin/env sh

sourced=0
if [ -n "$ZSH_VERSION" ]; then
	case $ZSH_EVAL_CONTEXT in *:file) sourced=1;; esac
elif [ -n "$KSH_VERSION" ]; then
	[ "$(cd -- "$(dirname -- "$0")" && pwd -P)/$(basename -- "$0")" != "$(cd -- "$(dirname -- "${.sh.file}")" && pwd -P)/$(basename -- "${.sh.file}")" ] && sourced=1
elif [ -n "$BASH_VERSION" ]; then
	(return 0 2>/dev/null) && sourced=1
else
	case ${0##*/} in sh|-sh|dash|-dash) sourced=1;; esac
fi

if [ $sourced = 1 ]; then
	echo "Error: Script must NOT be sourced."
else
	## Git Repository
	# IMPORTANT: Change the value of GIT_REPO before running. Script will not execute with default setting.
	# Example: GIT_REPO='https://github.com/amjadodeh/zift-template.git'
	GIT_REPO='CHANGE_THIS'


	if [ "$GIT_REPO" = "CHANGE_THIS" ]; then
		echo "Error: The value of GIT_REPO is '$GIT_REPO'"
		echo "Please change value of GIT_REPO before running the script."
		exit 1
	fi

	SCRIPT_DIR="$(dirname "$(realpath "$0")")"
	cd $SCRIPT_DIR

	if [ "$PWD" = "$SCRIPT_DIR" ]; then
		rm -rf ./* ./.*
		git clone $GIT_REPO .
		echo "done!"
	fi
fi

