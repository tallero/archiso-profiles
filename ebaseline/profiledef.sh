#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux-ebaseline"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="Arch Linux <https://archlinux.org>"
iso_application="Arch Linux baseline"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso' 'dongle')
images=(["cdr"]="700000:iso:1"
	["dvd"]="4200000:iso:1"
	["ssd"]="120000000:iso:1"
	["usb"]="64000000:dongle:1")
bootmodes=('bios.grub.mbr'
           'bios.grub.eltorito'
           'uefi-ia32.grub.esp'
           'uefi-ia32.grub.eltorito'
           'uefi-x64.grub.esp'
           'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs+luks"
airootfs_image_tool_options=('-zlz4hc,12' -E ztailpacking)
airootfs_encryption_key="auto"
persistent_size=200000 # 200MB
persistent_image_type="ext4+luks"
persistent_encryption_key="auto"
dongle_persistent_encryption_key="auto"
swap_size=250000 # 250MB
swap_image_type="swap+luks"
keys_image_type="erofs+luks"
keys_encryption_key="auto"
keys_image_tool_options=('-zlz4hc,12' -E ztailpacking)
file_permissions=(
  ["/etc/crypttab"]="0:0:400"
  ["/etc/shadow"]="0:0:400"
  ["/home"]="0:0:711"
  ["/run/archiso/keys"]="0:0:700"
  ["/run/archiso/persistent"]="0:0:711"
  ["/usr/local/bin/missing-dongle"]="0:0:755"
  ["/usr/local/bin/user-setup"]="0:0:755"
  ["/usr/local/bin/resolve-dev-mapper-donglepersistent"]="0:0:755"
  ["/usr/local/bin/resolve-dev-mapper-persistent"]="0:0:755"
  ["/var/lib/bluetooth"]="0:0:755"
)
