FROM armbuild/debian:latest
RUN apt-get update && \
    apt-get install -yq dnsmasq wget
ENV ARCH amd64
ENV DIST jessie
ENV MIRROR http://ftp.nl.debian.org
RUN mkdir /tftp
WORKDIR /tftp

RUN wget $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/netboot.tar.gz
RUN tar xvfz netboot.tar.gz
RUN rm netboot.tar.gz
CMD \
    echo Starting DHCP Proxy+TFTP server...&&\
    dnsmasq --bind-interfaces \
			--except-interface=lo \
    	    --dhcp-range=192.168.2.255,proxy \
		--port=0 \
	    --dhcp-boot=pxelinux.0,pxeserver,$myIP \
	    --pxe-service=x86PC,"Install Linux",pxelinux \
	    --enable-tftp --tftp-root=/tftp/ --no-daemon
# Let's be honest: I don't know if the --pxe-service option is necessary.
# The iPXE loader in QEMU boots without it.  But I know how some PXE ROMs
# can be picky, so I decided to leave it, since it shouldn't hurt.
