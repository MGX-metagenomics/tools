
FROM ubuntu:18.04

LABEL version="1.0"
LABEL maintainer="sebastian@jaenicke.org"

# build dependencies
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install \
    git wget make gcc g++ zlib1g-dev unzip autoconf file cpio

# runtime dependencies
#
# libxml2: magicblast
# libperl5.26: Sys::Hostname for bowtie2
# python: bowtie2
RUN apt-get -y install libgomp1 libxml2 libperl5.26 openjdk-8-jre-headless python

RUN groupadd mgxserv && useradd -m -g mgxserv mgxserv && chown -R mgxserv /home/mgxserv

COPY . /tmp/tools
RUN cd /tmp/tools && for f in `cat build_order`; do \
       bash -x ${f}.build || exit 1; \
    done

RUN apt-get -y purge git wget make gcc g++ zlib1g-dev unzip autoconf file cpio
RUN apt-get -y autoremove && apt-get -y clean && rm -rf /tmp/tools && \
    rm -rf /var/lib/apt/lists/* /var/lib/dpkg/info/* /var/log/dpkg.log /root/.wget-hsts

#USER mgxserv
