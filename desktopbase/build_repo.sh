#!/usr/bin/env bash

unset mode

_makepkg() {
    local _pkgname="${1}"
    git clone "https://aur.archlinux.org/${_pkgname}"
    cd "${_pkgname}" || exit
    makepkg
    mv "${_pkgname}"*".pkg.tar."* "${_server}"
}

_build_pkg() {
    local _pkgname="${1}"
    local _mode="${2}"
    local _pwd
    _pwd="$(pwd)"

    if [ "${_mode}" = "src" ]; then
        _makepkg "${_pkgname}"
    elif [ "${_mode}" = "fakepkg" ]; then
        cd "${_server}" || exit
        fakepkg "${_pkgname}"
    fi

    cd "${_server}" || exit
    repo-add "${_profile}.db.tar.gz" "${_pkgname}"*".pkg.tar."*
    cd "${_pwd}" || exit
}

_build_repo() {
    local _mode="${1}"
    local _profile
    _profile=$(basename "$(pwd)")
    local _server="/tmp/archiso-profiles/${_profile}"
    rm -rf repo "${_server}" && mkdir -p repo "${_server}"
    cd repo || exit
    gpg --recv-keys "D9B0577BD93E98FC" # cryptsetup
    _build_pkg "cryptsetup-nested-cryptkey" "${_mode}"
    _build_pkg "mkinitcpio-archiso-persistent-git" "${_mode}"
    _build_pkg "plymouth-nested-cryptkey" "${_mode}"
    _build_pkg "archiso-encryption-git" "${_mode}"
    _build_pkg "st" "${_mode}"
    _build_pkg "dwm" "${_mode}"
    cd ..
    rm -rf repo
}

new_behaviour=false

while getopts 'm:' opt; do
        new_behavior=true

        case $opt in
                m)
                        mode=$OPTARG
                        ;;
                *)
                        echo 'Error in command line parsing' >&2
                        exit 1
        esac
done

if ! "${new_behaviour}"; then
        # Fall back on old behavior.

        mode=$1;       shift
fi

_build_repo "${mode}"
