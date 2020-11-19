FROM lablup/backendai-krunner-wheels:static-gnu AS wheels

FROM lablup/backendai-krunner-python:static-gnu

ARG PREFIX=/opt/backend.ai

COPY --from=wheels /root/wheels/* /root/wheels/
COPY requirements.txt /root/
RUN ${PREFIX}/bin/python3 -m pip install --no-cache-dir --no-index -f /root/wheels -r /root/requirements.txt && \
    ${PREFIX}/bin/python3 -m pip list

# Create directories to be used for additional bind-mounts by the agent
RUN PYVER_MM="$(echo $PYTHON_VERSION | cut -d. -f1).$(echo $PYTHON_VERSION | cut -d. -f2)" && \
    mkdir -p "${PREFIX}/lib/python${PYVER_MM}/site-packages/ai/backend/kernel" && \
    mkdir -p "${PREFIX}/lib/python${PYVER_MM}/site-packages/ai/backend/helpers"
RUN if test ! -f "${PREFIX}/bin/python" -a ! -h "${PREFIX}/bin/python" ; then \
      ln -s "${PREFIX}/bin/python3" "${PREFIX}/bin/python"; \
    fi

COPY ttyd_linux.x86_64.bin ${PREFIX}/bin/ttyd
RUN chmod +x ${PREFIX}/bin/ttyd

# Build the image archive
RUN apt-get update && apt-get install -y xz-utils
RUN cd ${PREFIX}; \
    tar cJf /root/image.tar.xz ./*

LABEL ai.backend.krunner.version=7
CMD ["${PREFIX}/bin/python"]

# vim: ft=dockerfile
