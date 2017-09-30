#!/usr/bin/make -f

MODULES = \
	vmblock \
	vmci \
	vmmon \
	vmnet \
	vsock

TARDIR = /usr/lib/vmware/modules/source

MAJOR_VERSION = 308
KVERSION = $(shell uname -r)
MODULE_DIRS = $(addsuffix -only, $(MODULES))

KERNEL_INFO = $(subst -, , ${KVERSION})
KERNEL_VERSION = $(word 1, ${KERNEL_INFO})
KERNEL_VERSION_INFO = $(subst ., , ${KERNEL_VERSION})
KERNEL_MAJOR_VERSION = $(word 1, ${KERNEL_VERSION_INFO}).$(word 2, ${KERNEL_VERSION_INFO})
KERNEL_MINOR_VERSION = $(word 3, ${KERNEL_VERSION_INFO})


all:  $(MODULE_DIRS)  patch $(MODULES)

%.ko: % %
	$(MAKE) KVERSION=$(KVERSION) VM_KBUILD=yes MODULEBUILDDIR=$(MODULEBUILDDIR) -C $*-only
	mv $*.o $*.ko

$(MODULE_DIRS): $(foreach m, $(MODULES), $m.ko)  patch

$(MODULES): %: $(TARDIR)/%.tar
	tar xf $<
	chmod -R +w $*-only

patch: $(MODULES)
	echo "===Patching vmware-module ${MAJOR_VERSION} for kernel ${KVERSION}==="; \
	for PATCH_ITEM in *.patch ; do \
		IFS='-' read -a PATCH_ITEM_INFO <<< "$${PATCH_ITEM}"; \
		PATCH_MAJOR_VERSION=$${PATCH_ITEM_INFO[0]}; \
		PATCH_KERNEL_MAJOR_VERSION=($${PATCH_ITEM_INFO[1]}); \
		PATCH_KERNEL_MINOR_VERSION=$${PATCH_ITEM_INFO[2]}; \
		if [ ${MAJOR_VERSION} -ne $${PATCH_MAJOR_VERSION} ]; then \
			echo "===Passed $${PATCH_ITEM}==="; \
			continue; \
		fi; \
		if [ $$(echo "${KERNEL_MAJOR_VERSION} >= $${PATCH_KERNEL_MAJOR_VERSION}" | bc -l) ]; then \
			msg=`patch -Ns -p0 < $${PATCH_ITEM} || 1>&2`; \
			if [ "$$msg" = "" ]; then \
				echo "===Patched $${PATCH_ITEM}==="; \
			else \
				echo "===Failed to patch $${PATCH_ITEM}==="; \
				echo "$$msg"; \
			fi; \
		fi; \
	done


clean:
	rm -rf $(MODULES)
	rm -rf $(foreach m, $(MODULES), $m-only)
	rm -f  $(foreach m, $(MODULES), $m.ko)
	rm -f  $(foreach m, $(MODULES), $m.o)
