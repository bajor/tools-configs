import argparse
import hashlib
import json
import re
from collections.abc import Mapping
from pathlib import Path


def validate(*, manifest: Mapping, payloads: Mapping[str, bytes]) -> tuple[str, ...]:
    errors = []
    source = manifest.get('source', manifest.get('upstream', {}))
    if not re.fullmatch(pattern=r'[a-f0-9]{40}', string=source.get('commit', '')):
        errors.append('missing immutable upstream commit')
    records = manifest.get('files', manifest.get('integrity', {}).get('files', {}))
    if set(records) != set(payloads):
        errors.append('payload inventory differs from provenance')
    for relative, record in records.items():
        expected = record.get('sha256') if isinstance(record, dict) else record
        actual = hashlib.sha256(payloads.get(relative, b'')).hexdigest()
        if expected != actual:
            errors.append(f'payload digest mismatch: {relative}')
    license_record = records.get('LICENSE', {})
    original_license = source.get('license_sha256')
    if not original_license and isinstance(license_record, dict):
        original_license = license_record.get('upstream_sha256')
    if not original_license or hashlib.sha256(payloads.get('LICENSE', b'')).hexdigest() != original_license:
        errors.append('missing or changed upstream license')
    if 'SKILL.md' not in payloads:
        errors.append('missing SKILL.md')
    return tuple(errors)


def inspect(*, directory: Path) -> tuple[str, ...]:
    if directory.is_symlink() or not directory.is_dir():
        return ('package must be a real directory',)
    paths = tuple(directory.rglob('*'))
    if any(path.is_symlink() for path in paths):
        return ('symlink in package',)
    if any(not path.is_file() and not path.is_dir() for path in paths):
        return ('nonregular payload in package',)
    try:
        manifest = json.loads(s=directory.joinpath('provenance.json').read_text(encoding='utf-8'))
        if not isinstance(manifest, dict):
            return ('provenance must be a JSON object',)
        payloads = {path.relative_to(directory).as_posix(): path.read_bytes()
                    for path in paths if path.is_file() and path != directory / 'provenance.json'}
        return validate(manifest=manifest, payloads=payloads)
    except (OSError, ValueError, TypeError, AttributeError) as error:
        return (f'invalid package: {error}',)


def main() -> int:
    parser = argparse.ArgumentParser(description='Check recorded skill bytes, inventory and license. This is not source authentication, discovery or workflow verification.')
    parser.add_argument('--package', type=Path, action='append', required=True)
    options = parser.parse_args()
    failed = False
    for directory in options.package:
        errors = inspect(directory=directory)
        print(f'{directory}: ' + ('; '.join(errors) if errors else 'payload inventory, digests and license match'))
        failed = failed or bool(errors)
    return int(failed)


if __name__ == '__main__':
    raise SystemExit(main())
