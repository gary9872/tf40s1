# Maintainer: Gary Hunt <garysbox@gmail.com>

pkgname=tinyfugue
pkgver=4.0s1
pkgrel=3
arch=('i686' 'x86_64')
pkgdesc="flexible, screen-oriented MUD client, for use with any type of MUD"
url="http://tinyfugue.sourceforge.net/"
license=("GPL")
depends=(pcre zlib ncurses openssl)
source=("git https://github.com/gary9872/tf40s1.git")
sha256sums=('SKIP')

# build function
build() {
	cd $srcdir/tf40s1

	./configure --prefix=/usr --enable-termcap=ncurses
	make
}

# package function
package() {
	cd $srcdir/tinyfugue

	mkdir $pkgdir/usr
	make prefix=$pkgdir/usr install
}
