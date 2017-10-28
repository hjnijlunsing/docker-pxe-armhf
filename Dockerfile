FROM armbuild/debian:latest
RUN apt-get update && \
    apt-get install -yq dnsmasq wget
ENV ARCH amd64
ENV DIST jessie
ENV MIRROR http://ftp.nl.debian.org
RUN mkdir /tftp
WORKDIR /tftp
RUN wget $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/linux
RUN wget $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/initrd.gz
RUN wget $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/pxelinux.0
RUN mkdir pxelinux.cfg
RUN printf "DEFAULT linux\nLABEL linux\nKERNEL linux\nAPPEND initrd=initrd.gz\n" >pxelinux.cfg/default
CMD \
    echo Starting DHCP Proxy+TFTP server...&&\
    dnsmasq --interface=eth1 \
    	    --dhcp-range=192.168.2.255,proxy \
		--port=0 \
	    --dhcp-boot=pxelinux.0,pxeserver,$myIP \
	    --pxe-service=x86PC,"Install Linux",pxelinux \
	    --enable-tftp --tftp-root=/tftp/ --no-daemon
# Let's be honest: I don't know if the --pxe-service option is necessary.
# The iPXE loader in QEMU boots without it.  But I know how some PXE ROMs
# can be picky, so I decided to leave it, since it shouldn't hurt.
