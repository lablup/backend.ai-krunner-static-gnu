# syntax=docker/dockerfile-upstream:1-labs
ARG ARCH=x86_64
FROM quay.io/pypa/manylinux2014_${ARCH}

ARG PREFIX=/opt/backend.ai
ARG ARCH=x86_64

ENV PATH=${PREFIX}/bin:$PATH \
    PYTHON_VERSION=3.13.2 \
    LANG=C.UTF-8

RUN yum install -y \
	wget \
	tar \
	ca-certificates

RUN <<-EOF
    set -ex
    mkdir -p ${PREFIX}
    cd /root
    if [ "${ARCH}" = "x86_64" ]; then
      wget -q -O python.tar.gz "https://github.com/astral-sh/python-build-standalone/releases/download/20250317/cpython-3.13.2+20250317-x86_64_v2-unknown-linux-gnu-install_only_stripped.tar.gz"
    else
      wget -q -O python.tar.gz "https://github.com/astral-sh/python-build-standalone/releases/download/20250317/cpython-3.13.2+20250317-aarch64-unknown-linux-gnu-install_only_stripped.tar.gz"
    fi
    tar -xzC . -f python.tar.gz
    mv /root/python/* ${PREFIX}/
    # aarch64 version does not have pip installed...
    ${PREFIX}/bin/python3 -m ensurepip
    rm -f python.tar.gz
EOF

RUN python3 -c 'import sys; print(sys.version_info); print(sys.prefix)'


# vim: ft=dockerfile tw=0
