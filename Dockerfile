
FROM ubuntu:18.04 AS builder

LABEL version="1.0"
LABEL maintainer="sebastian@jaenicke.org"

# build dependencies
RUN apt-get -y update && apt-get -y upgrade && apt-get -y install \
    git wget make gcc g++ zlib1g-dev unzip autoconf file cpio \
    cmake \
    libboost-program-options-dev libboost-iostreams-dev \
    libboost-graph-dev libboost-system-dev libboost-filesystem-dev libboost-serialization-dev

# runtime dependencies
#
# libxml2: magicblast
# libperl5.26: Sys::Hostname for bowtie2
# python: bowtie2
# metaphlan2: python, python-numpy
# metabat: boost
# checkm: python-numpy python-pysam python-dendropy python-matplotlib
RUN apt-get -y install libgomp1 libxml2 libperl5.26 openjdk-8-jre-headless python python-numpy \
    libboost-program-options1.65.1 libboost-iostreams1.65.1 \
    libboost-graph1.65.1 libboost-system1.65.1 libboost-filesystem1.65.1 libboost-serialization1.65.1

RUN groupadd mgxserv && useradd -m -g mgxserv mgxserv && chown -R mgxserv /home/mgxserv

COPY . /tmp/tools
RUN cd /tmp/tools && for f in `cat build_order`; do \
       bash -x ${f}.build || exit 1; \
    done

#RUN apt-get -y purge git wget make gcc g++ zlib1g-dev unzip autoconf file cpio \
#    cmake \
#    libboost-program-options-dev libboost-iostreams-dev \
#    libboost-graph-dev libboost-system-dev libboost-filesystem-dev libboost-serialization-dev
#
#RUN apt-get -y autoremove && apt-get -y clean && rm -rf /tmp/tools && \
#    rm -rf /var/lib/apt/lists/* /var/lib/dpkg/info/* /var/log/dpkg.log /root/.wget-hsts

FROM ubuntu:18.04 

# runtime dependencies
RUN apt-get -y update && apt-get -y install libgomp1 libxml2 libperl5.26 openjdk-8-jre-headless python python-numpy \
    libboost-program-options1.65.1 libboost-iostreams1.65.1 \
    libboost-graph1.65.1 libboost-system1.65.1 libboost-filesystem1.65.1 libboost-serialization1.65.1 \
    python-numpy python-pysam python-dendropy python-matplotlib

COPY --from=builder /vol/mgx-sw/ /vol/mgx-sw
COPY --from=builder /etc/profile.d/mgx-sw.sh /etc/profile.d/

#USER mgxserv
