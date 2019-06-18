FROM gentoo/portage:latest as portage
FROM gentoo/stage3-amd64-nomultilib:latest

LABEL maintainer="linuxer (at) quantentunnel.de"

# copy the entire portage volume
COPY --chown=portage:portage --from=portage /usr/portage /usr/portage

# after this command, /var/tmp and /usr/portage/distfiles is volatile, maybe kept by caller
VOLUME /var/tmp
VOLUME /usr/portage/distfiles

# configure portage and crossdev overlay
COPY host-files/ /

# configure portage
# chown crossdev overlay
RUN chown -R portage:portage /usr/local/portage-crossdev && \
# install crossdev, some utilities
# install joe cause nano sucks hard
	emerge --quiet 	app-editors/joe \
			app-portage/layman \
			sys-devel/crossdev \
			dev-util/quilt \
			dev-util/cmake \
			dev-lang/swig \
			app-misc/screen \
			app-portage/gentoolkit \
			dev-embedded/u-boot-tools \
			sys-apps/dtc \
			sys-fs/f2fs-tools \
			sys-fs/mtd-utils \
			sys-fs/nilfs-utils && \
	emerge -uDN --quiet @world && \
# cleanup
	eselect locale set C.utf8

CMD /bin/bash -il
