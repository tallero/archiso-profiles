#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux-desktop"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="Arch Linux <https://archlinux.org>"
iso_application="Arch Linux Desktop"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso' 'dongle')
bootmodes=('bios.syslinux.mbr'
           'bios.syslinux.eltorito'
	   'uefi-ia32.grub.esp'
           'uefi-ia32.grub.eltorito'
           'uefi-x64.systemd-boot.esp'
           'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs+luks"
airootfs_image_tool_options=('-zlz4hc,12')
encryption_key="auto"
keys_image_type="erofs+luks"
keys_image_tool_options=('-zlz4hc,12')
keys_encryption_key="auto"
persistent_image_type="ext4+luks"
persistent_size="3000000" # 3GB
persistent_encryption_key="auto"
dongle_persistent_size="3000000" # 3GB
dongle_persistent_encryption_key="auto"
swap_image_type="swap+luks"
swap_size="2000000" # 2GB
dongle_swap_size="2000000" # 2GB
recovery="true"
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/run/archiso/keys"]="0:0:700"
  ["/usr/local/bin/setup-persistent-storage"]="0:0:755"
)
