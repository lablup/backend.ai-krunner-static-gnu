# backend.ai-krunner-ubuntu
Backend.AI Kernel Runner Package for Ubuntu-based Kernels

## How to update

1. Modify Dockerfile and/or other contents.
2. Increment *the volume version number* specified as a label `ai.backend.krunner.vesrion`
   in `src/ai/backend/krunner/ubuntu/krunner-env.{distro-version}.dockerfile`
   (there may be multiple dockerfiles).
3. Run `scripts/build.py {distro-version}`.
4. Repeat the above steps for each distro version.
5. Increment *the package version number* in `src/ai/backend/krunner/ubuntu/__init__.py`
6. `rm -r dist/* build/*` (skip if these directories do not exist and or are empty)
7. `python setup.py sdist bdist_wheel`
8. `twine upload dist/*`

`{distro-version}` is a string like `ubuntu18.04`, `centos7.6`, `alpine3.10`, etc.
