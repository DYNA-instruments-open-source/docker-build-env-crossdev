FROM gentoo/portage:latest as portage
FROM gentoo/stage3-amd64-nomultilib:latest
ARG MERGE_JOBS

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
	eselect locale set C.utf8

# update world
RUN emerge --noreplace ${MERGE_JOBS} sys-devel/distcc && \
    emerge -uDN ${MERGE_JOBS} @world
# install some utilities
# install joe cause nano sucks hard
RUN emerge --noreplace ${MERGE_JOBS} \
			app-editors/joe \
			app-portage/layman \
			dev-util/quilt \
			dev-util/cmake \
			dev-util/ninja \
			dev-lang/swig \
			app-misc/screen \
			app-portage/gentoolkit
# install crossdev, kernel and embedded tools
RUN ln -s -f -T cp /bin/ps2pdf && \
    emerge --noreplace ${MERGE_JOBS} \
    			sys-kernel/gentoo-sources \
    			sys-devel/crossdev \
			dev-embedded/u-boot-tools \
			sys-apps/dtc \
			sys-fs/f2fs-tools \
			sys-fs/mtd-utils \
			sys-fs/nilfs-utils \
			dev-embedded/srecord && \
# cleanup \
   rm /bin/ps2pdf

CMD /bin/bash -il
