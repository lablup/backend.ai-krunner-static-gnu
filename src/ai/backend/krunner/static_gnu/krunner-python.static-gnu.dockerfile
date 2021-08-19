# syntax=docker/dockerfile-upstream:1-labs
FROM ubuntu:20.04

ARG PREFIX=/opt/backend.ai
ARG ARCH=x86_64

ENV PATH=${PREFIX}/bin:$PATH \
    PYTHON_VERSION=3.9.6 \
    LANG=C.UTF-8

RUN apt-get update \
    && apt-get install -y \
	wget \
	tar \
	zstd \
	ca-certificates

RUN <<-EOF
    set -ex
    mkdir -p ${PREFIX}
    cd /root
    if [ "${ARCH}" = "x86_64" ]; then
      wget -O python.tar.zst "https://github.com/indygreg/python-build-standalone/releases/download/20210724/cpython-3.9.6-${ARCH}-unknown-linux-gnu-pgo-20210724T1424.tar.zst"
    else
      wget -O python.tar.zst "https://github.com/indygreg/python-build-standalone/releases/download/20210724/cpython-3.9.6-${ARCH}-unknown-linux-gnu-noopt-20210724T1424.tar.zst"
    fi
    tar -I zstd -xC . --strip-components=1 -f python.tar.zst
    mv /root/install/* ${PREFIX}/
    mv /root/licenses ${PREFIX}/
    rm -f python.tar.zst
EOF

RUN python3 -c 'import sys; print(sys.version_info); print(sys.prefix)'


# vim: ft=dockerfile tw=0
