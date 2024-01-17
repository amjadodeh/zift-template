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
	SCRIPT_DIR="$(dirname "$(realpath "$0")")"
	cd $SCRIPT_DIR
	. ./.config
	PATTERN="${PATTERN}.tar.gz.gpg"

	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		echo "Usage: $0"
		echo "  [file ...]  Process specific files matching the pattern '$PATTERN'"
		exit
	else
		stty -echo
		printf "Enter passphrase: "
		read SECRET_PASSPHRASE
		stty echo
		printf "\n"
		echo ""
		for file in *; do
			case "$file" in
				$PATTERN)
					echo "File '$file' matches the pattern"

					zift=$file
					new_zift=${file%.tar.gz.gpg}

					gpg --batch --passphrase "$SECRET_PASSPHRASE" --decrypt "$zift" | tar xzf - && rm -rf "$zift"

					if [ -f "$zift" ]; then
						echo "Decryption Failed: '$zift'"
					elif [ -e "$new_zift" ]; then
						echo "Decryption Complete: '$zift' -> '$new_zift'"
					fi
					;;
				encrypt.sh.tar.gz.gpg)
					echo "Decrypting 'encrypt.sh.tar.gz.gpg'"

					gpg --batch --passphrase "$SECRET_PASSPHRASE" --decrypt "encrypt.sh.tar.gz.gpg" | tar xzf - && rm -rf "encrypt.sh.tar.gz.gpg"

					if [ -f "encrypt.sh" ]; then
						echo "Decryption Complete: 'encrypt.sh.tar.gz.gpg' -> 'encrypt.sh'"
					fi
					;;
				*)
					echo "Skipping '$file': doesn't match pattern"
					;;
			esac
			echo ""
		done
	fi
fi

