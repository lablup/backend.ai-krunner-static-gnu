ARG ARCH=x86_64
FROM quay.io/pypa/manylinux2014_${ARCH}

ENV PATH=$PATH:/opt/python/cp313-cp313/bin

COPY requirements.txt /root/

RUN set -ex \
    && cd /root \
    && pip3 wheel -w ./wheels -r requirements.txt


# vim: ft=dockerfile
