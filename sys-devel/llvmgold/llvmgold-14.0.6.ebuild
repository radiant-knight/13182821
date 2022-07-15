# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
inherit toolchain-funcs llvm llvm.org

DESCRIPTION="Gold Linker Plugin API wrapper for LLVM LibLTO"
HOMEPAGE="https://llvm.org/"

LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA GPL-3"
SLOT="$(ver_cut 1)"
KEYWORDS="~amd64 ~x86"

PDEPEND="~sys-devel/llvm-${PV}:${SLOT}="
BDEPEND="
	>=dev-util/cmake-3.16
	${PYTHON_DEPS}"

LLVM_COMPONENTS=( llvm/tools/gold )
llvm.org_set_globals

pkg_setup() {
	LLVM_MAX_SLOT=${SLOT} llvm_pkg_setup
}

src_configure() { :; }

src_compile() {
	sed -i '\@^#include "llvm/Config/config.h"@d' gold-plugin.cpp || die # excise it from the build system
	$(tc-getCXX) $CXXFLAGS \
		-I"${FILESDIR}/include" -I"/usr/$(get_libdir)/llvm/$SLOT/include/" -DHAVE_STDINT_H \
		gold-plugin.cpp -fPIC -shared -o LLVMgold.so || die
}

src_install() {
	install -Dm644 LLVMgold.so "${D}/usr/$(get_libdir)/llvm/$SLOT/lib/LLVMgold.so" || die
}
