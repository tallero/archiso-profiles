def install_arch_install_scripts():
  !sudo apt install asciidoc bsdtar build-essential libarchive-dev m4 git python-pip >/dev/null 2>&1
  !sudo pip install meson ninja >/dev/null 2>&1
  !git clone https://github.com/archlinux/arch-install-scripts >/dev/null 2>&1
  !make -C arch-install-scripts > /dev/null 2>&1
  !sudo make -C arch-install-scripts PREFIX=/usr DESTDIR="/" install > /dev/null 2>&1


def install_asp():
  !git clone https://github.com/falconindy/asp.git >/dev/null 2>&1
  !make -C asp >/dev/null 2&1
  !sudo make -C asp PREFIX=/usr DESTDIR="/" install >/dev/null 2>&1
  !sudo install -Dm644 asp/LICENSE "/usr/share/licenses/asp/LICENSE" >/dev/null 2>&1

def install_pacman():
  !rm -rf pacman
  !git clone https://gitlab.archlinux.org/pacman/pacman >/dev/null 2>&1

  !cd pacman && meson --prefix=/usr --buildtype=plain -Ddoc=disabled -Ddoxygen=disabled -Dscriptlet-shell=/usr/bin/bash -Dldconfig=/usr/bin/ldconfig build

  !cd pacman && meson compile -C build

  !cd pacman && DESTDIR="/" meson install -C build

  # install Arch specific stuff
  !cd pacman && install -dm755 "/etc"
  !cd pacman && install -m644 "build/pacman.conf" "/etc"
  !cd pacman && install -m644 "build/makepkg.conf" "/etc"

def install_archiso():
  !git clone https://gitlab.archlinux.org/tallero/archiso
  !cd archiso && git checkout crypto
  !cd archiso &&


install_arch_install_scripts()
install_asp()
install_pacman()
