# backend.ai-krunner-static-gnu
Backend.AI Kernel Runner Package for glibc-based Kernels

This package contains a statically built Python distribution and 3rd-party libraries required to run
[our krunner module](https://github.com/lablup/backend.ai/tree/main/src/ai/backend/kernel)
inside containers whose images are provided by users.

The krunner wheel itself can be installed into any Python environments (the content of this plugin
package is agnostic to platforms and architectures as it's a mere declaration of the plugin
interface), but we still apply the binary wheel platform tags so that setuptools could distinguish
the target CPU architecture as follows:

| Where is Backend.AI running? | What is the user container's base image? | The krunner wheel used |
|------------------------------|------------------------------------------|------------------------|
| manylinux (x86-64)           | manylinux (x86-64)                       | `backend.ai_krunner_static_gnu-X.X.X-py3-none-manylinux2014_x86_64.musllinux_1_1_x86_64.macosx_11_0_x86_64.whl` |
| manylinux (x86-64)           | musllinux (x86-64)                       | `backend.ai_krunner_alpine-X.X.X-py3-none-manylinux2014_x86_64.musllinux_1_1_x86_64.macosx_11_0_x86_64.whl` |
| manylinux (aarch64)          | manylinux (aarch64)                      | `backend.ai_krunner_static_gnu-X.X.X-py3-none-manylinux2014_aarch64.musllinux_1_1_aarch64.macosx_11_0_arm64.whl` |
| manylinux (aarch64)          | musllinux (aarch64)                      | `backend.ai_krunner_alpine-X.X.X-py3-none-manylinux2014_aarch64.musllinux_1_1_aarch64.macosx_11_0_arm64.whl` |
| musllinux (x86-64)           | manylinux (x86-64)                       | `backend.ai_krunner_static_gnu-X.X.X-py3-none-manylinux2014_x86_64.musllinux_1_1_x86_64.macosx_11_0_x86_64.whl` |
| musllinux (x86-64)           | musllinux (x86-64)                       | `backend.ai_krunner_alpine-X.X.X-py3-none-manylinux2014_x86_64.musllinux_1_1_x86_64.macosx_11_0_x86_64.whl` |
| musllinux (aarch64)          | manylinux (aarch64)                      | `backend.ai_krunner_static_gnu-X.X.X-py3-none-manylinux2014_aarch64.musllinux_1_1_aarch64.macosx_11_0_arm64.whl` |
| musllinux (aarch64)          | musllinux (aarch64)                      | `backend.ai_krunner_alpine-X.X.X-py3-none-manylinux2014_aarch64.musllinux_1_1_aarch64.macosx_11_0_arm64.whl` |
| macOS (x86-64)               | manylinux (x86-64)                       | `backend.ai_krunner_static_gnu-X.X.X-py3-none-manylinux2014_x86_64.musllinux_1_1_x86_64.macosx_11_0_x86_64.whl` |
| macOS (x86-64)               | musllinux (x86-64)                       | `backend.ai_krunner_alpine-X.X.X-py3-none-manylinux2014_x86_64.musllinux_1_1_x86_64.macosx_11_0_x86_64.whl` |
| macOS (aarch64)              | manylinux (aarch64)                      | `backend.ai_krunner_static_gnu-X.X.X-py3-none-manylinux2014_aarch64.musllinux_1_1_aarch64.macosx_11_0_arm64.whl` |
| macOS (aarch64)              | musllinux (aarch64)                      | `backend.ai_krunner_alpine-X.X.X-py3-none-manylinux2014_aarch64.musllinux_1_1_aarch64.macosx_11_0_arm64.whl` |

We named the krunner package based on musl 1.2 as "alpine" because practically Alpine linux is the
only distribution which actively uses musl and it is currently not possible to build static CPython
which can import 3rd-party dynamic modules on top of the musl ecosystem.

## Notice about source distribution

This package is to distribute prebuilt binaries, so the source distribution does not have prebuilt
binaries and does not work as intended.  Just refer this repository on how we build stuffs.

## How to read below

* `{distro}` is a string like `static-gnu`, `alpine`, etc. depending on which repository you are in.
* `{distro_}` is a string same to `{distro}` but with hyphens replaced with underscores for Python
  package names and paths. (e.g., `static_gnu`, `alpine`)

## Development

```console
$ git clone https://github.com/lablup/backend.ai-krunner-{distro} krunner-{distro}
$ cd krunner-{distro}
$ uv sync
```

To build wheels locally, replace `ARCH` in `MANIFEST.in` with the current architecture (e.g.,
"aarch64" or "x86_64"). Then:

```console
$ uv run python scripts/build.py
$ uv build
```

## How to update

1. Modify Dockerfile and/or other contents.
  - To update the Python version, update `src/ai/backend/krunner/{distro_}/krunner-python.{distro}.txt`
    and the dockerfiles (both _python_ and _wheels_) accordingly, including the
    `PYTHON_VERSION` environment variable and the download URL of the
    statically built Python distribution.
2. Increment *the volume version number* specified as a label `ai.backend.krunner.version`
   in `src/ai/backend/krunner/{distro_}/krunner-env.{distro}.dockerfile`.
3. Increment *the package version number* in `src/ai/backend/krunner/{distro_}/__init__.py`.
4. Run `uv run python scripts/build.py` to confirm if the volume archive build is successfully done.
5. Repeat the above steps for each distro version. (For static builds, there is only one.)
6. `rm -r dist/* build/*` (skip if these directories do not exist and or are empty)
7. Commit.
8. Create a signed annotated tag and push the tag to let GitHub Action build and publish wheels.

Note that `src/ai/backend/krunner/{distro_}/krunner-version.{distro}.txt` files are
overwritten by the build script from the label.

WARNING: We should choose [`x86_64_v2` binaries from the indygreg repository](https://gregoryszorc.com/docs/python-build-standalone/main/running.html)
when updating the Python runtime version for CPU compatibility with some of our
test setups and customer sites.

## Making a minimal glibc-based image compatibile with this krunner package

[Use CentOS 7 or later and install this list of packages.](https://github.com/lablup/backend.ai-krunner-static-gnu/blob/master/compat-test.Dockerfile)
Also [refer the test script](https://github.com/lablup/backend.ai-krunner-static-gnu/blob/main/scripts/test.sh).

## Build custom ttyd binary

**⚠️ Warning: Use a x86-64 host to build ttyd, because:**
  - ttyd uses `musl` as their C stdlib, not `glibc`.
  - The `musl` toochain used by the build script is x86_64 binaries.

`libwebsockets>=4.0.0` features auto ping/pong with 5 min default interval.
(https://github.com/warmcat/libwebsockets#connection-validity-tracking) And,
`ws_ping_pong_interval` of ttyd is not effective in `libwebsockets>=4.0.0`.
This seems to be the reason why `ttyd>=1.6.1` does not set
`ws_ping_pong_interval` for `libwebsockets>=4.0.0`.
(https://github.com/tsl0922/ttyd/blob/master/src/server.c#L456)

To fix this issue, we modify and build the latest version of `libwebsockets` used by the ttyd build script manually.

```console
# Prepare Ubuntu environment (possibly, through container) and dependencies.
sudo apt-get update
sudo apt-get install -y autoconf automake build-essential cmake curl file libtool

# Download ttyd source.
git clone https://github.com/tsl0922/ttyd.git
cd ttyd
```

Now let's modify `./scripts/cross-build.sh`.
Add these two lines under `pushd "${BUILD_DIR}/libwebsockets-${LIBWEBSOCKETS_VERSION}"`:
```sh
sed -i 's/context->default_retry.secs_since_valid_ping = 300/context->default_retry.secs_since_valid_ping = 20/g' lib/core/context.c
sed -i 's/context->default_retry.secs_since_valid_hangup = 310/context->default_retry.secs_since_valid_hangup = 30/g' lib/core/context.c
```

Finally, build the `ttyd` binary.
```console
# Run build script.
./scripts/cross-build.sh

# Check ttyd binary version.
./build/ttyd --version
```
