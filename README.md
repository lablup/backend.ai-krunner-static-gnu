# backend.ai-krunner-static-gnu
Backend.AI Kernel Runner Package for glibc-based Kernels

## Notice about source distribution

This package is to distribute prebuilt binaries, so the source distribution does not have prebuilt
binaries and does not work as intended.  Just refer this repository on how we build stuffs.

## How to read below

* `{distro}` is a string like `static-gnu`, `static-musl`, etc. depending on which repository you are in.
* `{distro_}` is a string same to `{distro}` but with hyphens replaced with underscores for Python
  package names and paths. (e.g., `static_gnu`, `static_musl`)

## Development

```console
$ git clone https://github.com/lablup/backend.ai-krunner-{distro} krunner-{distro}
$ cd krunner-{distro}
$ pyenv virtualenv 3.9.6 venv-krunner  # you may share the same venv with other krunner projects
$ pyenv local venv-krunner
$ pip install -U pip setuptools
$ pip install -U click -e .
```

## How to update

1. Modify Dockerfile and/or other contents.
  - To update the Python version, update `src/ai/backend/krunner/{distro_}/krunner-python.{distro}.txt`
    and the dockerfiles accordingly, including the `PYTHON_VERSION` environment variable and the download
    URL of the statically built Python distribution.
2. Increment *the volume version number* specified as a label `ai.backend.krunner.version`
   in `src/ai/backend/krunner/{distro_}/krunner-env.{distro}.dockerfile`
3. Run `scripts/build.py`.
4. Repeat the above steps for each distro version. (For static builds, there is only one.)
5. Increment *the package version number* in `src/ai/backend/krunner/{distro_}/__init__.py`
6. `rm -r dist/* build/*` (skip if these directories do not exist and or are empty)
7. `python setup.py sdist bdist_wheel`
8. `twine upload dist/*`

Note that `src/ai/backend/krunner/{distro_}/krunner-version.{distro}.txt` files are
overwritten by the build script from the label.

## Build custom ttyd binary

**⚠️ Warning: ttyd uses `musl` as their C stdlib, not `glibc`. Also, trying to run cross-build script on aarch64-based machine will not work, since `musl` toochain used on the script is x86_64 binary.** 

`libwebsockets>=4.0.0` features auto ping/pong with 5 min default interval.
(https://github.com/warmcat/libwebsockets#connection-validity-tracking) And,
`ws_ping_pong_interval` of ttyd is not effective in `libwebsockets>=4.0.0`.
This seems to be the reason why `ttyd>=1.6.1` does not set
`ws_ping_pong_interval` for `libwebsockets>=4.0.0`.
(https://github.com/tsl0922/ttyd/blob/master/src/server.c#L456)

We solved this by modifying latest version of `libwebsockets`' source manually. In order to achieve this, 
you'll need to modify ttyd's build script.

```console
# Prepare Ubuntu environment (possibly, through container) and dependencies.
sudo apt-get update
sudo apt-get install -y autoconf automake build-essential cmake curl file libtool

# Download ttyd source.
git clone https://github.com/tsl0922/ttyd.git
cd ttyd

# Edit ./scripts/cross-build.sh as you want.
# For example, set `LIBWEBSOCKETS_VERSION="3.2.3"`
```
Now add these two lines under `pushd "${BUILD_DIR}/libwebsockets-${LIBWEBSOCKETS_VERSION}"`:
```console
sed -i 's/context->default_retry.secs_since_valid_ping = 300/context->default_retry.secs_since_valid_ping = 20/g' lib/core/context.c 
sed -i 's/context->default_retry.secs_since_valid_hangup = 310/context->default_retry.secs_since_valid_hangup = 30/g' lib/core/context.c 
```
You can now start building `ttyd` binary.   
```console
# Run build script.
./scripts/cross-build.sh

# Check ttyd binary version.
./build/ttyd --version
```
