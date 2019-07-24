import json
import secrets
import subprocess
from pathlib import Path
import platform
import pkg_resources

import click


@click.group()
def main():
    '''
    Entrypoint.
    '''
    pass


@main.command()
@click.argument('distro', default='ubuntu16.04')
def build_krunner_env(distro: str):
    '''
    Build the kernel runner environment containers and tar archives which provides the /opt/backend.ai
    volume to all other kernel contaienrs.
    '''
    base_path = Path(pkg_resources.resource_filename('ai.backend.krunner.ubuntu', '.'))
    click.secho(f'Building Python for krunner for {distro}', fg='yellow', bold=True)
    subprocess.run([
        'docker', 'build',
        '-f', f'krunner-python.{distro}.dockerfile',
        '-t', f'lablup/backendai-krunner-python:{distro}',
        '.'
    ], cwd=base_path, check=True)
    click.secho(f'Building krunner for {distro}', fg='yellow', bold=True)
    cid = secrets.token_hex(8)
    arch = platform.machine()  # docker builds the image for the current arch.
    subprocess.run([
        'docker', 'build',
        '-f', f'krunner-env.{distro}.dockerfile',
        '-t', f'krunner-env.{distro}',
        '.'
    ], cwd=base_path, check=True)
    subprocess.run([
        'docker', 'create',
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
