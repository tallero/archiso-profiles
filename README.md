# `archiso-profiles`

This repository contain additional 
[Archiso](https://aur.archlinux.org/archlinux/archiso)
profiles. It depends on `archiso-encryption-git` 
([`AUR`](https://aur.archlinux.org/packages/archiso-encryption-git)).

### Profiles

All the included profiles are such that when put on a writable medium
they become functional portable systems.

#### `ebaseline` <br> <sub>*`archlinux-ebaseline`* ([`AUR`](https://aur.archlinux.org/packages/archlinux-ebaseline))</sub>
Encryption-enabled replica of `baseline`:
```yaml
- airootfs_image_type: "erofs+luks";
- keys_image_type: "squashfs+luks";
- buildmodes: "iso" and "dongle";
- cryptsetup-sigfile: replaces "cryptsetup";
- mkinitcpio-archiso-encryption: replaces "mkinitcpio-archiso";
```

#### `desktopbase` <br> <sub>*`archlinux-desktopbase-git`* ([`AUR`](https://aur.archlinux.org/packages/archlinux-desktopbase-git))</sub>
Base desktops based on `ebaseline` without apps. Same options as `desktop`.

```yaml
- keys_image_type: erofs+luks
- plymouth-luks-cryptkey: replaces `plymouth`
```

#### `desktop` <br> <sub>*`archlinux-desktop`* ([`AUR`](https://aur.archlinux.org/packages/archlinux-desktop))</sub>
Desktop profile based on `desktopbase` including common productivity apps.

##### Apps
- Abiword
- Firefox
- Gnumeric
- gitg
- Marker
- mpv

#### `ereleng` <br> <sub>*`archlinux`* ([`AUR`](https://aur.archlinux.org/packages/archlinux))</sub>

Encryption-enabled replica of `releng`:
```yaml
- airootfs_image_type: "squashfs+luks"
- keys_image_type: "erofs+luks";
- buildmodes: "iso" and "keys"
- cryptsetup-luks-cryptkey: replaces "cryptsetup"
- mkinitcpio-archiso-encryption: replaces "mkinitcpio-archiso"
```

#### `life` <br> <sub>*`life`* ([`AUR`](https://aur.archlinux.org/packages/life))</sub>

A desktop profile with a focus on security, development and user-experience.

```yaml
- airootfs_image_type: "squashfs+luks"
- keys_image_type: "erofs+luks";
- buildmodes: "iso" and "keys"
- cryptsetup-sigfile: replaces "cryptsetup"
- mkinitcpio-archiso-encryption: replaces "mkinitcpio-archiso"
```

### Download <br> <sub>[*Google Colab*](https://colab.research.google.com/github/tallero/archiso-profiles/blob/noapps/jupyter/jupyter.ipynb)</sub>

### Build

```console
git clone https://gitlab.archlinux.org/tallero/archiso-profiles
make DESTDIR="/" PREFIX=/usr install -C archiso-profiles
```
 
then as with any other Archiso profile:

```console
$ cd archiso-profiles/<profile>
$ mkarchisorepo src
# mkarchiso -v ./ 
```

### License

All the code is released under GNU Affero General Public License version 3.
