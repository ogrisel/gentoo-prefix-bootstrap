#!/bin/bash

hash -r

set -x
set -e

source ./update_env.sh
. ./update_env.sh

make uninstall-force

hash -r
make install/stage1
make install/stage2-up-to-bison

# make -n install/stage2
#emerge --nodeps tar

#ACCEPT_KEYWORDS="**" emerge --nodeps "=app-arch/tar-1.23*"
#mkdir -p ${EPREFIX}/usr/portage/app-arch/tar
#cp -vf files/local_overlay/app-arch/tar/tar-1.23-r4.ebuild ${EPREFIX}/usr/portage/app-arch/tar/
#ebuild ${EPREFIX}/usr/portage/app-arch/tar/tar-1.23-r4.ebuild manifest
#emerge --nodeps "=app-arch/tar-1.23*"

#mkdir -p ${EPREFIX}/usr/portage/app-arch/tar files/local_overlay/
#cp -a ${EPREFIX}/usr/portage/app-arch/tar files/local_overlay/

#emerge --nodeps tar
#LIBRARY_PATH=/usr/lib/x86_64-linux-gnu emerge --nodeps --oneshot binutils gcc-config '=gcc-4.2*'
emerge --nodeps --oneshot binutils
emerge --nodeps --oneshot gcc-config
emerge --nodeps app-arch/tar
LIBRARY_PATH=/usr/lib/x86_64-linux-gnu emerge --nodeps --oneshot '=gcc-4.2*'

