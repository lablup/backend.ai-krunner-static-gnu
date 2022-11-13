# syntax=docker/dockerfile-upstream:1-labs
FROM ubuntu:20.04

ARG PREFIX=/opt/backend.ai
ARG ARCH=x86_64

ENV PATH=${PREFIX}/bin:$PATH \
    PYTHON_VERSION=3.10.8 \
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
      wget -q -O python.tar.zst "https://github.com/indygreg/python-build-standalone/releases/download/20221106/cpython-3.10.8+20221106-x86_64_v3-unknown-linux-gnu-pgo-full.tar.zst"
    else
      wget -q -O python.tar.zst "https://github.com/indygreg/python-build-standalone/releases/download/20221106/cpython-3.10.8+20221106-aarch64-unknown-linux-gnu-noopt-full.tar.zst"
    fi
    tar -I zstd -xC . --strip-components=1 -f python.tar.zst
    mv /root/install/* ${PREFIX}/
    mv /root/licenses ${PREFIX}/
    # aarch64 version does not have pip installed...
    ${PREFIX}/bin/python3 -m ensurepip
    rm -f python.tar.zst
EOF

RUN python3 -c 'import sys; print(sys.version_info); print(sys.prefix)'


# vim: ft=dockerfile tw=0
