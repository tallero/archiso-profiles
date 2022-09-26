#!/usr/bin/env bash
#
# This script is run within a virtual environment to build the available archiso profiles and their available build
# modes and create checksum files for the resulting images.
# The script needs to be run as root and assumes $PWD to be the root of the repository.
#
# Dependencies:
# * all archiso dependencies
# * coreutils
# * gnupg
# * openssl
# * zsync
#
# $1: profile
# $2: buildmode

set -euo pipefail
shopt -s extglob

readonly orig_pwd="${PWD}"
readonly output="${orig_pwd}/output"
readonly tmpdir_base="${orig_pwd}/tmp"
readonly profile="${1}"
readonly buildmode="${2}"
readonly install_dir="arch"

tmpdir=""
tmpdir="$(mktemp --dry-run --directory --tmpdir="${tmpdir_base}")"
gnupg_homedir=""
codesigning_dir=""
codesigning_cert=""
codesigning_key=""
pgp_key_id=""

signature_info() {
  sig_country="DE"
  sig_state="Berlin"
  sig_city="Berlin"
  sig_org="Arch Linux"
  sig_unit="Release Engineering"
  sig_domain="archlinux.org"
  sig_email="arch-releng@lists.${sig_domain}"
  sig_comment="Ephemeral Signing Key"
}

print_section_start() {
  # gitlab collapsible sections start: https://docs.gitlab.com/ee/ci/jobs/#custom-collapsible-sections
  local _section _title
  _section="${1}"
  _title="${2}"

  printf "\e[0Ksection_start:%(%s)T:%s\r\e[0K%s\n" '-1' "${_section}" "${_title}"
}

print_section_end() {
  # gitlab collapsible sections end: https://docs.gitlab.com/ee/ci/jobs/#custom-collapsible-sections
  local _section
  _section="${1}"

  printf "\e[0Ksection_end:%(%s)T:%s\r\e[0K\n" '-1' "${_section}"
}

cleanup() {
  # clean up temporary directories
  print_section_start "cleanup" "Cleaning up temporary directory"

  if [ -n "${tmpdir_base:-}" ]; then
    rm -fr "${tmpdir_base}"
  fi

  print_section_end "cleanup"
}

create_checksums() {
  # create checksums for files
  # $@: files
  local _file_path _file_name _current_pwd
  _current_pwd="${PWD}"

  print_section_start "checksums" "Creating checksums"

  for _file_path in "$@"; do
    cd "$(dirname "${_file_path}")"
    _file_name="$(basename "${_file_path}")"
    b2sum "${_file_name}" > "${_file_name}.b2"
    md5sum "${_file_name}" > "${_file_name}.md5"
    sha1sum "${_file_name}" > "${_file_name}.sha1"
    sha256sum "${_file_name}" > "${_file_name}.sha256"
    sha512sum "${_file_name}" > "${_file_name}.sha512"
    ls -lah "${_file_name}."{b2,md5,sha{1,256,512}}
    cat "${_file_name}."{b2,md5,sha{1,256,512}}
  done
  cd "${_current_pwd}"

  print_section_end "checksums"
}

create_zsync_delta() {
  # create zsync control files for files
  # $@: files
  local _file

  print_section_start "zsync_delta" "Creating zsync delta"

  for _file in "$@"; do
    if [[ "${buildmode}" == "bootstrap" ]]; then
      # zsyncmake fails on 'too long between blocks' with default block size on bootstrap image
      zsyncmake -v -b 512 -C -u "${_file##*/}" -o "${_file}".zsync "${_file}"
    else
      zsyncmake -v -C -u "${_file##*/}" -o "${_file}".zsync "${_file}"
    fi
  done

  print_section_end "zsync_delta"
}

create_metrics() {
  local _metrics="${output}/metrics.txt"
  # create metrics
  print_section_start "metrics" "Creating metrics"

  {
    # create metrics based on buildmode
    case "${buildmode}" in
      iso)
        printf 'image_size_mebibytes{image="%s"} %s\n' \
          "${profile}" \
          "$(du -m -- "${output}/"*.iso | cut -f1)"
        printf 'package_count{image="%s"} %s\n' \
          "${profile}" \
          "$(sort -u -- "${tmpdir}/iso/"*/pkglist.*.txt | wc -l)"
        if [[ -e "${tmpdir}/efiboot.img" ]]; then
          printf 'eltorito_efi_image_size_mebibytes{image="%s"} %s\n' \
            "${profile}" \
            "$(du -m -- "${tmpdir}/efiboot.img" | cut -f1)"
        fi
        # shellcheck disable=SC2046
        # shellcheck disable=SC2183
        printf 'initramfs_size_mebibytes{image="%s",initramfs="%s"} %s\n' \
          $(du -m -- "${tmpdir}/iso/"*/boot/**/initramfs*.img | \
            awk -v profile="${profile}" \
            'function basename(file) {
              sub(".*/", "", file)
              return file
            }
            { print profile, basename($2), $1 }'
          )
        ;;
      netboot)
        printf 'netboot_size_mebibytes{image="%s"} %s\n' \
          "${profile}" \
          "$(du -m -- "${output}/${install_dir}/" | tail -n1 | cut -f1)"
        printf 'netboot_package_count{image="%s"} %s\n' \
          "${profile}" \
          "$(sort -u -- "${tmpdir}/iso/"*/pkglist.*.txt | wc -l)"
        ;;
      bootstrap)
        printf 'bootstrap_size_mebibytes{image="%s"} %s\n' \
          "${profile}" \
          "$(du -m -- "${output}/"*.tar*(.gz|.xz|.zst) | cut -f1)"
        printf 'bootstrap_package_count{image="%s"} %s\n' \
          "${profile}" \
          "$(sort -u -- "${tmpdir}/"*/bootstrap/root.*/pkglist.*.txt | wc -l)"
        ;;
    esac
  } > "${_metrics}"
  ls -lah "${_metrics}"
  cat "${_metrics}"

  print_section_end "metrics"
}

create_ephemeral_keys() {
  local _gen_key
  local _gen_key_options=('ephemeral') _gpg_options=() _openssl_options=()
  _gen_key="$(pwd)/.gitlab/ci/gen_key.sh"
  [ -e "${_gen_key}" ] || _gen_key="mkarchisogenkey"
  print_section_start "ephemeral_pgp_key" "Creating ephemeral PGP key"
  local gnupg_homedir="${tmpdir}/.gnupg"
  signature_info
  _gpg_options+=("${gnupg_homedir}"
                 "${sig_email}"
                 "${sig_unit}"
                 "${sig_comment}")
  "${_gen_key}" "${_gen_key_options[@]}" 'gpg' "${_gpg_options[@]}"
  create_ephemeral_pgp_key
  print_section_end "ephemeral_pgp_key"
  print_section_start "ephemeral_codesigning_key" "Creating ephemeral codesigning key"
  codesigning_dir="${tmpdir}/.codesigning/"
  _openssl_options+=("${codesigning_dir}"
                     "${sig_country}"
                     "${sig_state}"
                     "${sig_city}"
                     "${sig_org}"
                     "${sig_unit}"
                     "${sig_domain}")
  "${_gen_key}" "${_gen_key_options[@]}" 'openssl' "${_openssl_options[@]}"
  print_section_end "ephemeral_codesigning_key"
}

setup_repo() {
  local _build_repo _build_repo_options=() _packages _setup_user
  local _build_repo_options=('src'
                             'packages.extra'
			     "/tmp/archiso-profiles/${profile}")
  _build_repo="$(pwd)/.gitlab/ci/build_repo.sh"
  _setup_user="$(pwd)/.gitlab/ci/setup_user.sh"
  [ -e "${_build_repo}" ] || _build_repo="mkarchisorepo"
  print_section_start "setup_repo" "Setup ${profile} ${buildmode} additional packages"
  "${_setup_user}"
  cp -r "${profile}" /home/user
  chown -R user "/home/user/${profile}"
  su user -c "cd ${profile} && ${_build_repo} ${_build_repo_options[@]}"
  #shellcheck disable=SC1091
  source "${profile}/packages.extra"
  cp "${profile}"/pacman.conf /etc/pacman.conf
  pacman -Sy "${_packages[@]}"
  print_section_end "setup_repo"
}

run_mkarchiso() {
  local _archiso_options=()
  mkdir -p "${output}/" "${tmpdir}/"
  create_ephemeral_keys
  setup_repo

  _archiso_options+=('-D' "${install_dir}" 
                     '-c' "${codesigning_cert} ${codesigning_key}"
                     '-g' "${pgp_key_id}"
                     '-G' "${pgp_sender}"
                     '-o' "${output}/"
                     '-w' "${tmpdir}/"
                     '-v')

  if [ "${buildmode}" != "iso" ]; then
    _archiso_options+=('-m' "${buildmode}")
  fi

  print_section_start "mkarchiso" "Running mkarchiso"
  # shellcheck disable=SC2154
  GNUPGHOME="${gnupg_homedir}" mkarchiso "${_archiso_options[@]}"
                                         "${profile}"
  print_section_end "mkarchiso"

  if [[ "${buildmode}" =~ "iso" ]]; then
    create_zsync_delta "${output}/"*.iso
    create_checksums "${output}/"*.iso
  fi
  if [[ "${buildmode}" == "bootstrap" ]]; then
    create_zsync_delta "${output}/"*.tar*(.gz|.xz|.zst)
    create_checksums "${output}/"*.tar*(.gz|.xz|.zst)
  fi
  create_metrics

  print_section_start "ownership" "Setting ownership on output"

  if [[ -n "${SUDO_UID:-}" ]] && [[ -n "${SUDO_GID:-}" ]]; then
    chown -Rv "${SUDO_UID}:${SUDO_GID}" -- "${output}"
  fi
  print_section_end "ownership"
}

trap cleanup EXIT

run_mkarchiso
