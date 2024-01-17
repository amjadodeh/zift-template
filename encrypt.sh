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
	## Decryption Passphrase
	# WARNING: Change the default SECRET_PASSPHRASE immediately! Risk of data breach!
	SECRET_PASSPHRASE="CHANGE_THIS_NOW"


	SCRIPT="$(basename "$(realpath "$0")")"
	SCRIPT_DIR="$(dirname "$(realpath "$0")")"
	cd $SCRIPT_DIR
	. ./config.sh

	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "Usage: $(basename $0) [OPTION]"
		echo "OPTIONS:"
		echo "  -c, --clear			Run 'gpgconf --reload gpg-agent' to clear cached passphrases."
		echo "  -h, --help			Show this screen."
		echo ""
		echo "Example:"
		echo "  $(basename $0) -c"
		echo "      This encrypts '$(basename $0)' (itself), all files in '$SCRIPT_DIR' mathing the pattern '$PATTERN', and clears cached passphrases."
		exit
	fi

	for zift in $PATTERN; do
		echo "Encrypting '$zift'"
		tar czf - "$zift" | gpg --symmetric --batch --passphrase "$SECRET_PASSPHRASE" -o "$zift.tar.gz.gpg" && rm -rf "$zift"
	done

	echo "Encrypting '$SCRIPT'"
	tar czf - "$SCRIPT" | gpg --symmetric --batch --passphrase "$SECRET_PASSPHRASE" -o "$SCRIPT.tar.gz.gpg" && rm -rf "$SCRIPT"

	if [ "$1" = "-c" ] || [ "$1" = "--clear" ]; then
		gpgconf --reload gpg-agent
		echo "Cached passphrases cleared."
	fi

	echo "Done!"
fi

