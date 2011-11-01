ifndef SCIENTIFIC_MK
SCIENTIFIC_MK=scientific.mk

include init.mk
include tools.mk

scientific: tools bc gparallel ipython atlas numpy scipy matplotlib joblib \
	scikits.learn

# ----------------------------------------------------------------------------
bc:
	${EMERGE} -uDN bc

gparallel:
	cd ${EPREFIX}/usr/local/portage && ${EPREFIX}/usr/portage/scripts/ecopy sys-process/parallel
	${EMERGE} -uDN sys-process/parallel

pip:
	${EMERGE} -uDN setuptools
	easy_install -U pip

ipython: pip
	${PIP} install -UI ipython

atlas:
	${EMERGE} -uDN cblas blas
	${EMERGE} -uDN blas-atlas
	eselect blas set atlas-threads || exit 0
	eselect cblas set atlas-threads || exit 0
	${EMERGE} -uDN lapack
	${EMERGE} -uDN lapack-atlas
	eselect lapack set atlas || exit 0

numpy: atlas local-overlay
	echo "dev-python/numpy doc lapack test" >> ${EPREFIX}/etc/portage/package.use/numpy
	${EMERGE} -uDN --onlydeps numpy
	FEATURES=test ${EMERGE} -uN numpy

scipy: numpy util-linux
	# -- arpack: workaround linking the wrong libgfortran
	mkdir -p ${EPREFIX}/etc/portage/env/sci-libs/
	echo "export LDFLAGS=\"-L$(shell echo $(shell dirname $(shell echo $(shell find ${EPREFIX}/usr/lib/ -name "libfortran.so" | tail -n1))))\"" >> ${EPREFIX}/etc/portage/env/sci-libs/arpack
	#$LDFLAGS=-L$(shell echo $(shell dirname $(shell echo $(shell find /usr/lib/ -name "libfortran.so" | tail -n1)))) emerge -uDN arpack
	emerge -uDN arpack
	# XXX: scipy.test() still segfaults, due to superlu or atlas.
	# It might be related to gfortran/g77, see:
	# http://comments.gmane.org/gmane.comp.python.scientific.devel/15541
	# http://comments.gmane.org/gmane.comp.python.scientific.devel/4399
	#${EMERGE} -uDN --onlydeps scipy
	#FEATURES=test ${EMERGE} -uN scipy
	${EMERGE} -uDN scipy

matplotlib: numpy
	${EMERGE} -uDN matplotlib

pycuda: pip
	${PIP} install -UI pycuda

joblib: pip
	${PIP} install -UI joblib

scikits.learn: pip
	${PIP} install -UI scikits.learn

mongodb: local-overlay pip
	${EMERGE} -uDN portage-utils
	cd ${EPREFIX}/usr/local/portage && ${EPREFIX}/usr/portage/scripts/ecopy dev-db/mongodb
	echo "dev-db/mongodb v8" >> ${EPREFIX}/etc/portage/package.use/mongodb
	echo "dev-lang/v8 **" >> ${EPREFIX}/etc/portage/package.keywords/mongodb
	echo "dev-db/mongodb **" >> ${EPREFIX}/etc/portage/package.keywords/mongodb
	# mongodb workarounds
	-rm -vf ${EPREFIX}/etc/portage/env/dev-db/mongodb
	mkdir -p ${EPREFIX}/etc/portage/env/dev-db
	echo "export LDFLAGS=\"-L/usr/lib -L${EPREFIX}/usr/lib\"" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	echo "export CXXFLAGS=\"-I/usr/include -I${EPREFIX}/usr/include \"" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	echo "export CXX=${EPREFIX}/usr/bin/g++" >> ${EPREFIX}/etc/portage/env/dev-db/mongodb
	${EMERGE} -uDN mongodb
	${PIP} install -UI pymongo
	# Useful aliases from:
	# http://www.bitcetera.com/en/techblog/2011/02/15/nosql-on-mac-os-x
	# alias mongo-start="mongod --fork --dbpath \${EPREFIX}/var/lib/mongodb --logpath \${EPREFIX}/var/log/mongodb.log"
	# alias mongo-stop="killall -SIGTERM mongod 2>/dev/null"
	# alias mongo-status="killall -0 mongod 2>/dev/null; if [ \$? -eq 0 ]; then echo 'started'; else echo 'stopped'; fi"

endif
