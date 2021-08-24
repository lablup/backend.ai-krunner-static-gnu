### 2.0.0 (2021-08-24)

* Add support for arm64 (aarch64) Linux containers by introducing automated build pipeline
  using GitHub Actions and Docker's QEMU-based cross build tools.
  - The produced wheel package is marked compatible with manylinux 2014, musllinux 1.1,
    and macOS 11.0 or later.
* Exclude pre-built binaries from the source distribution due to the PyPI size limit.

### 1.0.1 (2020-11-20)

* Explicitly embed the licenses of all statically built and pre-installed binaries and packages.

### 1.0.0 (2020-11-19)

* Initial release of the `static-gnu` krunner-env package with a statically built Python 3.8.6.
