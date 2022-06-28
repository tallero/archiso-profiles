# Archiso profiles

This repository contain additional archiso profiles.
It depends on `archiso-encryption`.

## Profiles

### `desktop`
Desktop profile.
- `airootfs_image_type`:`erofs+luks`;
- `keys_image_type`: `squashfs+luks`;
- `buildmodes`:`iso` and `keys`;
- `cryptsetup-luks-cryptkey` replaces `cryptsetup`;
- `mkinitcpio-archiso` is replaced by `mkinitcpio-archiso-encryption`;
- `encrypt` hook enabled.


### `ereleng`

Encryption-enabled replica of `releng`:
- `airootfs_image_type`: `squashfs+luks`;
- `keys_image_type`: `erofs+luks`;
- `buildmodes`:`iso` and `keys`;
- `cryptsetup-luks-cryptkey` replaces `cryptsetup`;
- `mkinitcpio-archiso` is replaced by `mkinitcpio-archiso-encryption`;
- `encrypt` hook enabled.

### `ebaseline`
Encryption-enabled replica of `baseline`:
- `airootfs_image_type`:`erofs+luks`;
- `keys_image_type`: `squashfs+luks`;
- `buildmodes`:`iso` and `keys`;
- `cryptsetup-luks-cryptkey` replaces `cryptsetup`;
- `mkinitcpio-archiso` is replaced by `mkinitcpio-archiso-encryption`;
- `encrypt` hook enabled.

### `desktop`

A GNOME based profile equipped with the basics.

## Download

The profiles can be built on
[Google Colab](https://colab.research.google.com/github/tallero/archiso-profiles/blob/noapps/jupyter/jupyter.ipynb).
