#!/usr/bin/env bash

set -Eeo pipefail

docker_process_init_files() {
    echo
    local f
    for f; do
	case "$f" in
	    *.sh)
		if [ -x "$f" ]; then
		    echo "$0: running $f"
		    "$f"
		else
		    echo "$0: sourcing $f"
		    . "$f"
		fi
		;;
	    *)
		echo "$0: ignoring $f"
		;;
	esac
	echo
    done
}

docker_process_init_files docker-entrypoint.d/*

exec "$@"
