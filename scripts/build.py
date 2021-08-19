import json
import secrets
import subprocess
from pathlib import Path
import platform
import pkg_resources

import click


default_distro = 'static-gnu'
default_arch = 'x86_64'


@click.command()
@click.argument('distro', default=default_distro)
@click.option('--arch', default=default_arch)
def main(distro, arch):
    '''
    Build the kernel runner environment containers and tar archives which provides the /opt/backend.ai
    volume to all other kernel contaienrs.
    '''
    base_path = Path(pkg_resources.resource_filename('ai.backend.krunner.static_gnu', '.'))
    if (base_path / f'krunner-wheels.{distro}.dockerfile').exists():
        click.secho(f'Building Python wheels for krunner for {distro}', fg='yellow', bold=True)
        subprocess.run([
            'docker', 'buildx', 'build',
            '--platform', f'linux/{arch}',
            '-f', f'krunner-wheels.{distro}.dockerfile',
            '-t', f'lablup/backendai-krunner-wheels:{distro}',
            '.'
        ], cwd=base_path, check=True)
    click.secho(f'Bundling static Python for krunner for {distro}', fg='yellow', bold=True)
    subprocess.run([
        'docker', 'buildx', 'build',
        '--arg', f'ARCH={arch}',
        '--platform', f'linux/{arch}',
        '-f', f'krunner-python.{distro}.dockerfile',
        '-t', f'lablup/backendai-krunner-python:{distro}',
        '.'
    ], cwd=base_path, check=True)
    click.secho(f'Building krunner for {distro}', fg='yellow', bold=True)
    cid = secrets.token_hex(8)
    arch = platform.machine()  # docker builds the image for the current arch.
    subprocess.run([
        'docker', 'buildx', 'build',
        '--platform', f'linux/{arch}',
        '--arg', f'ARCH={arch}',
        '-f', f'krunner-env.{distro}.dockerfile',
        '-t', f'krunner-env.{distro}',
        '.'
    ], cwd=base_path, check=True)
    subprocess.run([
        'docker', 'create',
        '--platform', f'linux/{arch}',
        '--name', cid,
        f'krunner-env.{distro}',
    ], cwd=base_path, check=True)
    try:
        subprocess.run([
            'docker', 'cp',
            f'{cid}:/root/image.tar.xz',
            str(base_path / f'krunner-env.{distro}.{arch}.tar.xz'),
        ], cwd=base_path, check=True)
        proc = subprocess.run([
            'docker', 'inspect', cid,
        ], cwd=base_path, stdout=subprocess.PIPE, check=True)
        cinfo = json.loads(proc.stdout)
        labels = cinfo[0]['Config']['Labels']
        version = labels['ai.backend.krunner.version']
        (base_path / f'krunner-version.{distro}.txt').write_text(str(version))
    finally:
        subprocess.run([
            'docker', 'rm', cid,
        ], cwd=base_path, check=True)


if __name__ == '__main__':
    main()
