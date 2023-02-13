#! /bin/bash

tempdir="$(pwd)/$(mktemp -d krunner-test.XXXXX)"
echo "Extracting the tarball into $tempdir ..."
tar xJf src/ai/backend/krunner/static_gnu/krunner-env.static-gnu.$(uname -m).tar.xz -C $tempdir

testimg="lablup/backendai-krunner-test:manylinux-latest"
echo "Building a minimal CentOS-based image to run the krunner ($testimg) ..."
docker build -t $testimg -f compat-test.Dockerfile .

echo "Running test commands with the unpacakged Python ..."
docker run --rm -it \
    -v $tempdir:/opt/backend.ai \
    $testimg \
    /opt/backend.ai/bin/python -V
# Try loading some C-based Python modules to test if there are any link problems or missing libraries
docker run --rm -it \
    -v $tempdir:/opt/backend.ai \
    $testimg \
    /opt/backend.ai/bin/python -c "import ssl; import zlib; import sqlite3; print('importing stdlib c module dependencies: ok')"
docker run --rm -it \
    -v $tempdir:/opt/backend.ai \
    $testimg \
    /opt/backend.ai/bin/python -c "import zmq; import uvloop; import attrs; import msgpack; import jupyter_client; print('importing krunner dependencies: ok')"

echo "Done."
sudo rm -rf $tempdir
