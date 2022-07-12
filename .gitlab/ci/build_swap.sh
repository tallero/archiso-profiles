#!/bin/sh

# file, size
_build_swap() {
    _out="${1}"
    _size="${2}"
    dd if=/dev/zero of="${_out}" bs=1M count="${_size}" status=progress
    chmod 0600 "${_out}"
    sync
    fsuuid="$(uuidgen --sha1 \
	              --namespace 93a870ff-8565-4cf3-a67b-f47299271a96 \
		      --name "$(date +%s)")"
    mkswap -L "swap" -U "${fsuuid}" "${_out}"
}

# file, size
_build_swap "${1}" "${2}"
