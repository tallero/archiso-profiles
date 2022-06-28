#@title Build archiso profiles

profile = "releng" #@param ["releng"]

#@markdown The first run takes probably half an hour, so take a coffee and don't
#@markdown close the page

#@markdown **NOTE:** Down run this on your local Ubuntu, you will break it.

def install_packaged_deps():
  !sudo apt install autopoint asciidoc bsdtar build-essential cmake dosfstools fakeroot flex git gnulib grub2 help2man intltool libgpgme11 libtool libzstd-dev m4 make mtools python-pip shellcheck squashfs-tools texinfo zstd #>/dev/null 2>&1
  !sudo pip install meson ninja >/dev/null 2>&1

def install_arch_install_scripts():
  !git clone https://github.com/archlinux/arch-install-scripts >/dev/null 2>&1
  !make -C arch-install-scripts > /dev/null 2>&1
  !sudo make -C arch-install-scripts PREFIX=/usr DESTDIR="/" install > /dev/null 2>&1

def install_asp():
  !git clone https://github.com/falconindy/asp.git >/dev/null 2>&1
  !make -C asp >/dev/null 2&1
  !sudo make -C asp PREFIX=/usr DESTDIR="" install >/dev/null 2>&1
  !sudo install -Dm644 asp/LICENSE "/usr/share/licenses/asp/LICENSE" >/dev/null 2>&1

def install_gpgme_error():
  !rm -rf libgpg-error-1.45
  !wget https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.45.tar.bz2
  !tar xf libgpg-error-1.45.tar.bz2
  !cd libgpg-error-1.45 && ./configure --prefix=/usr
  !cd libgpg-error-1.45 && make
  !cd libgpg-error-1.45 && DESTDIR="/" PREFIX="/usr" sudo make install

def install_gpgme():
  !rm -rf gpgme-1.17.1
  !wget https://www.gnupg.org/ftp/gcrypt/gpgme/gpgme-1.17.1.tar.bz2
  !tar xf gpgme-1.17.1.tar.bz2
  !cd gpgme-1.17.1 && ./configure --help # | grep qt
  !cd gpgme-1.17.1 && ./configure --prefix=/usr --disable-gpg-test --enable-languages="cl cpp" --disable-fd-passing --disable-static --disable-gpgsm-test
  !cd gpgme-1.17.1 && CFLAGS+=' -Wno-int-conversion' && CXXFLAGS+=' -Wno-int-conversion' make
  !cd gpgme-1.17.1 && DESTDIR="/" PREFIX="/usr" sudo make install

def install_pacman():
  !rm -rf pacman
  !mkdir /etc/pacman.d
  !git clone https://gitlab.archlinux.org/tallero/archiso archiso >/dev/null 2>&1
  !git clone https://gitlab.archlinux.org/pacman/pacman >/dev/null 2>&1
  
  !cd pacman && meson --prefix=/usr --buildtype=plain -Dgpgme=enabled -Ddoc=disabled -Ddoxygen=disabled -Dscriptlet-shell=/usr/bin/bash -Dldconfig=/usr/bin/ldconfig build #>/dev/null 2>&1
  !cd pacman && meson compile -C build #>/dev/null 2>&1
  !cd pacman && sudo DESTDIR="/" meson install -C build #>/dev/null 2>&1

  # install Arch specific stuff
  !cd pacman && sudo install -dm755 "/etc" >/dev/null 2&1
  !cd pacman && sudo install -m644 "build/pacman.conf" "/etc" >/dev/null 2>&1
  !cd pacman && sudo install -m644 "build/makepkg.conf" "/etc" >/dev/null 2>&1

  !echo "Server = https://geo.mirror.pkgbuild.com/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
  #!sed "/SigLevel/d" archiso/configs/releng/pacman.conf > pacman.conf
  !sudo cp archiso/configs/releng/pacman.conf /etc/pacman.conf
  # !sudo sed '/SigLevel/d' archiso/configs/releng/pacman.conf > /etc/pacman.conf
  !sudo pacman-key --init archlinux
  !sudo pacman -Sy

def install_archiso():
  !rm -rf archiso
  !git clone https://gitlab.archlinux.org/tallero/archiso archiso >/dev/null 2>&1
  !git checkout -C archiso -b crypto >/dev/null 2>&1
  !cd archiso && make -k check >/dev/null 2>&1
  !cd archiso && make DESTDIR="" PREFIX='/usr' install >/dev/null 2>&1

def install_zstd():
  !rm -rf zstd-1.5.2
  !wget https://github.com/facebook/zstd/releases/download/v1.5.2/zstd-1.5.2.tar.gz >/dev/null 2>&1
  !tar -xf zstd-1.5.2.tar.gz
  !cd zstd-1.5.2 && sed '/build static library to build tests/d' -i build/cmake/CMakeLists.txt
  !cd zstd-1.5.2 && sed 's/libzstd_static/libzstd_shared/g' -i build/cmake/tests/CMakeLists.txt
  !cd zstd-1.5.2 && CFLAGS+=' -ffat-lto-objects' && CXXFLAGS+=' -ffat-lto-objects' cmake -S build/cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=None -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib -DZSTD_BUILD_CONTRIB=ON -DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_TESTS=OFF -DZSTD_PROGRAMS_LINK_SHARED=ON && cmake --build build
  !cd zstd-1.5.2 && DESTDIR="/" cmake --install build
  !cd zstd-1.5.2 && ln -sf /usr/bin/zstd "/usr/bin/zstdmt"

def install_gettext():
  !wget https://ftp.gnu.org/gnu/gettext/gettext-0.21.tar.xz >/dev/null 2>&1
  !tar xf gettext-0.21.tar.xz >/dev/null 2>&1
  !cd gettext-0.21 && autoreconf -i >/dev/null 2>&1
  !cd gettext-0.21 && ./configure --prefix=/usr >/dev/null 2>&1
  !cd gettext-0.21 && make >/dev/null 2>&1
  !cd gettext-0.21 && sudo DISTDIR="/" make install >/dev/null 2>&1

def install_autoconf():
  !git clone https://git.savannah.gnu.org/git/autoconf.git >/dev/null 2>&1
  !cd autoconf && autoreconf -i >/dev/null 2>&1
  !cd autoconf && ./configure --prefix=/usr >/dev/null 2>&1
  !cd autoconf && make >/dev/null 2>&1
  !cd autoconf && sudo DESTDIR="/" PREFIX="/usr" make install >/dev/null 2>&1

def install_tar():
  # !apt-get build-dep tar >/dev/null 2>&1
  !wget https://ftp.gnu.org/gnu/tar/tar-1.34.tar.xz >/dev/null 2>&1
  !tar -xf tar-1.34.tar.xz >/dev/null 2>&1
  # !git clone https://git.savannah.gnu.org/git/tar.git
  #!cd tar-1.34 && autoreconf -i
  !cd tar-1.34 && FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
  !cd tar-1.34 && make
  !cd tar-1.34 && DESTDIR=/ PREFIX=/usr make install

def install_cmake():
  # !rm -rf cmake-3.23.2
  !wget https://github.com/Kitware/CMake/releases/download/v3.23.2/cmake-3.23.2.tar.gz >/dev/null 2>&1
  !tar xf cmake-3.23.2.tar.gz
  !cd cmake-3.23.2 && ./configure --prefix=/usr >/dev/null 2>&1
  !cd cmake-3.23.2 && make #>/dev/null 2>&1
  !cd cmake-3.23.2 && sudo DESTDIR="/" PREFIX="/usr" make install #>/dev/null 2>&1

def install_libarchive():
  !rm -rf libarchive-3.6.1
  !wget https://github.com/libarchive/libarchive/releases/download/v3.6.1/libarchive-3.6.1.tar.xz
  !tar xf libarchive-3.6.1.tar.xz
  !ls libarchive-3.6.1
  !cd libarchive-3.6.1 && cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
  !cd libarchive-3.6.1 && cmake --build build
  !cd libarchive-3.6.1 && DESTDIR="/" PREFIX="/usr" sudo cmake --install build

def install_grub():
  !apt install libfuse-dev
  !rm -rf grub-2.06
  !wget https://ftp.gnu.org/gnu/grub/grub-2.06.tar.xz >/dev/null 2>&1
  !tar xf grub-2.06.tar.xz
  !cd grub-2.06 && ./configure --prefix=/usr --with-platform="pc" --target i386 --enable-efiemu	--enable-mm-debug --enable-nls --enable-device-mapper --enable-cache-stats --enable-grub-mkfont --enable-grub-mount --prefix="/usr" --bindir="/usr/bin" --sbindir="/usr/bin" --mandir="/usr/share/man" --infodir="/usr/share/info" --datarootdir="/usr/share" --sysconfdir="/etc" --program-prefix="" --with-bootdir="/boot" --with-grubdir="grub" --disable-silent-rules --disable-werror >/dev/null 2>&1
  !cd grub-2.06 && make >/dev/null 2>&1
  !cd grub-2.06 && DESTDIR="/" PREFIX="/usr" sudo make install >/dev/null 2>&1
  !rm -rf grub-2.06
  !tar xf grub-2.06.tar.xz >/dev/null 2>&1
  !cd grub-2.06 && ./configure --prefix=/usr --with-platform="efi" --target i386	--enable-mm-debug --enable-nls --enable-device-mapper --enable-cache-stats --enable-grub-mkfont --enable-grub-mount --prefix="/usr" --bindir="/usr/bin" --sbindir="/usr/bin" --mandir="/usr/share/man" --infodir="/usr/share/info" --datarootdir="/usr/share" --sysconfdir="/etc" --program-prefix="" --with-bootdir="/boot" --with-grubdir="grub" --disable-silent-rules --disable-werror >/dev/null 2>&1
  !cd grub-2.06 && make >/dev/null 2>&1
  !cd grub-2.06 && DESTDIR="/" PREFIX="/usr" sudo make install >/dev/null 2>&1
  !rm -rf grub-2.06
  !tar xf grub-2.06.tar.xz
  !cd grub-2.06 && ./configure --prefix=/usr --with-platform="efi" --target x86_64	--enable-mm-debug --enable-nls --enable-device-mapper --enable-cache-stats --enable-grub-mkfont --enable-grub-mount --prefix="/usr" --bindir="/usr/bin" --sbindir="/usr/bin" --mandir="/usr/share/man" --infodir="/usr/share/info" --datarootdir="/usr/share" --sysconfdir="/etc" --program-prefix="" --with-bootdir="/boot" --with-grubdir="grub" --disable-silent-rules --disable-werror >/dev/null 2>&1
  !cd grub-2.06 && make >/dev/null 2>&1
  !cd grub-2.06 && DESTDIR="/" PREFIX="/usr" sudo make install >/dev/null 2>&1
  !wget https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/grub/trunk/sbat.csv
  !sed -e "s/%PKGVER%/2.06/" < "sbat.csv" > "/usr/share/grub/sbat.csv"

def install_reflector():
  !rm -rf reflector
  !git clone https://gitlab.archlinux.org/tallero/reflector
  !cd reflector && python3 setup.py install --prefix=/usr --root="/" --optimize=1
  !cd reflector && install -Dm644 "man/reflector.1.gz" "/usr/share/man/man1/reflector.1.gz"
  !cd reflector && install -Dm644 'reflector.service' "/usr/lib/systemd/system/reflector.service"
  !cd reflector && install -Dm644 'reflector.timer' "/usr/lib/systemd/system/reflector.timer"
  !cd reflector && install -Dm644 'reflector.conf' "/etc/xdg/reflector/reflector.conf"

def build_releng():
  # Builds the archlinux install image.
  #!cd archiso/configs/releng && rm -rf work out
  !cd archiso/configs/releng && mkarchiso -v .
  !cat /etc/pacman.conf | grep SigLevel

def build_ereleng():
  # Build an encrypted releng (encrypted).
  !rm -rf archiso-profiles >/dev/null 2>&1
  !git clone https://gitlab.archlinux.org/tallero/archiso-profiles >/dev/null 2>&1
  !useradd user >/dev/null 2>&1
  !chown -R user:user archiso-profiles /tmp
  !su user -c "cd archiso-profiles/ereleng && bash build_repo.sh"
  #!cd archiso-profiles/desktop && bash build_repo.sh

def install_unpackaged_deps():
  install_cmake()
  install_arch_install_scripts()
  install_gettext()
  install_autoconf()
  install_zstd()
  install_libarchive()
  install_gpgme_error()
  install_gpgme()
  install_pacman()
  install_grub()
  install_archiso()

def install_utilities():
  install_asp()
  install_reflector()

install_packaged_deps()
install_unpackaged_deps()
build_releng()
#build_ereleng()

