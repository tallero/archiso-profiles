#!/usr/bin/bash

# Generate an ephemeral PGP key for signing the rootfs image
_generate_ephemeral_pgp_key() {
  local gnupg_homedir="${1}"
  local _email="${2}"
  local _unit="${3}"
  local _comment="${4}"

  mkdir -p "${gnupg_homedir}"
  chmod 700 "${gnupg_homedir}"

  cat << __EOF__ > "${gnupg_homedir}"/gpg.conf
quiet
batch
no-tty
no-permission-warning
export-options no-export-attributes,export-clean
list-options no-show-keyring
armor
no-emit-version
__EOF__

  gpg --homedir "${gnupg_homedir}" --gen-key <<EOF
%echo Generating ephemeral $_unit key pair...
Key-Type: default
Key-Length: 3072
Key-Usage: sign
Name-Real: $_unit
Name-Comment: $_comment
Name-Email: $_email
Expire-Date: 0
%no-protection
%commit
%echo Done
EOF

  # shellcheck disable=SC2034
  pgp_key_id="$(
    gpg --homedir "${gnupg_homedir}" \
        --list-secret-keys \
        --with-colons \
        | awk -F':' '{if($1 ~ /sec/){ print $5 }}'
  )"

  # shellcheck disable=SC2034
  export pgp_sender="${_unit} (${_comment}) <${_email}>"

}

# Generate ephemeral certificates used for codesigning
_generate_ephemeral_openssl_key() {
  codesigning_dir="${1}"
  _country="${2}" # es. IT
  _state="${3}"
  _city="${4}"
  _org="${5}"
  _unit="${6}"
  _domain="${7}"
  local codesigning_conf="${codesigning_dir}/openssl.cnf"
  local codesigning_subj="/C=${_state}/ST=${_state}/L=${_city}/O=${_org}/OU=${_unit}/CN=${_domain}"
  codesigning_cert="${codesigning_dir}/codesign.crt"
  codesigning_key="${codesigning_dir}/codesign.key"
  mkdir -p "${codesigning_dir}"
  cp -- /etc/ssl/openssl.cnf "${codesigning_conf}"
  printf "\n[codesigning]\nkeyUsage=digitalSignature\nextendedKeyUsage=codeSigning\n" >> "${codesigning_conf}"
  openssl req \
      -newkey rsa:4096 \
      -keyout "${codesigning_key}" \
      -nodes \
      -sha256 \
      -x509 \
      -days 365 \
      -out "${codesigning_cert}" \
      -config "${codesigning_conf}" \
      -subj "${codesigning_subj}" \
      -extensions codesigning
}

_mode="${1}"
_type="${2}"
shift 2

_generate_"${_mode}"_"${_type}"_key "$@"
