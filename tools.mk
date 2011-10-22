ifndef TOOLS_MK
TOOLS_MK=tools.mk

include init.mk

# =================================================i===========================
# == tools
# ============================================================================

default: tools

tools: eix local-overlay layman portage-tools \
	ruby vim tmux console-tools

# ----------------------------------------------------------------------------
eix:
	emerge -uDN eix
	eix-update
ifeq ($(shell test -f ${EPREFIX}/etc/eix-sync.conf && grep "^-e" ${EPREFIX}/etc/eix-sync.conf), )
	echo -e '\055e' >> ${EPREFIX}/etc/eix-sync.conf
endif
	eix-sync

local-overlay: eix
	mkdir -p ${EPREFIX}/usr/local/portage/profiles
	# XXX: One could use a ifeq here
	#echo "PORTDIR_OVERLAY=\"\$${PORTDIR_OVERLAY} ${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
	echo "PORTDIR_OVERLAY=\"${EPREFIX}/usr/local/portage/\"" >> ${EPREFIX}/etc/make.conf
	echo "local-overlay" > ${EPREFIX}/usr/local/portage/profiles/repo_name
	eix-sync

layman: eix
	emerge -uDN layman
	layman -S
	-layman -a sekyfsr
	# XXX: One could use a ifeq here
	echo "source ${EPREFIX}/var/lib/layman/make.conf" >> ${EPREFIX}/etc/make.conf
	eix-sync

portage-tools: eix
	emerge -uDN app-portage/portage-utils
	emerge -uDN app-portage/gentoolkit
	emerge -uDN app-portage/gentoolkit-dev
	emerge -uDN autounmask

vim: eix ruby
	echo "app-editors/vim bash-completion vim-pager python ruby perl" >> ${EPREFIX}/etc/portage/package.use/vim
	# tinfo/ncurses workaround
	mkdir -p ${EPREFIX}/etc/portage/env/app-editors
	echo "export LDFLAGS=-lncurses" >> ${EPREFIX}/etc/portage/env/app-editors/vim
	emerge -uDN vim vim-core
	eselect bashcomp enable --global vim &> /dev/null | exit 0

ruby: eix
	echo 'dev-lang/ruby -ssl' >> ${EPREFIX}/etc/portage/package.use/ruby
	emerge -uDN ruby

tmux: eix
	# tinfo/ncurses workaround
	mkdir -p ${EPREFIX}/etc/portage/env/app-misc
	echo "export LDFLAGS=\"-l:/home/ac/npinto/gentoo/usr/lib/libevent.so \$$LDFLAGS\"" >> ${EPREFIX}/etc/portage/env/app-misc/tmux
	emerge -uDN tmux

console-tools: eix
	emerge -uDN keychain
	emerge -uDN zsh
	emerge -uDN htop
	emerge -uDN ncdu

endif
