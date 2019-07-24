FROM lablup/backendai-krunner-python:ubuntu16.04

ARG PREFIX=/opt/backend.ai

RUN apt-get update && apt-get install -y xz-utils
RUN ${PREFIX}/bin/pip install --no-cache-dir -U pip setuptools

COPY requirements.txt /root/
RUN ${PREFIX}/bin/pip install --no-cache-dir -U -r /root/requirements.txt && \
    ${PREFIX}/bin/pip list

# Create directories to be used for additional bind-mounts by the agent
RUN PYVER_MM="$(echo $PYTHON_VERSION | cut -d. -f1).$(echo $PYTHON_VERSION | cut -d. -f2)" && \
    mkdir -p ${PREFIX}/lib/python${PYVER_MM}/site-packages/ai/backend/kernel && \
    mkdir -p ${PREFIX}/lib/python${PYVER_MM}/site-packages/ai/backend/helpers

# Build the image archive
RUN cd ${PREFIX}; \
    tar cJf /root/image.tar.xz ./*

LABEL ai.backend.krunner.version=1
CMD ["${PREFIX}/bin/python"]

# vim: ft=dockerfile
