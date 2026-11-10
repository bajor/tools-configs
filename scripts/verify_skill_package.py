import argparse
import hashlib
import json
import os
import re
from collections.abc import Mapping
from pathlib import Path


def digest(*, value: object) -> bool:
    return isinstance(value, str) and re.fullmatch(pattern=r'[a-f0-9]{64}', string=value) is not None


def validate(*, manifest: Mapping, payloads: Mapping[str, bytes]) -> tuple[str, ...]:
    pstack = 'source' in manifest and 'files' in manifest
    apple = 'upstream' in manifest and 'integrity' in manifest
    if type(manifest.get('schema_version')) is not int or manifest['schema_version'] != 1 or pstack == apple:
        return ('unsupported or ambiguous provenance format',)
    if pstack and ('upstream' in manifest or 'integrity' in manifest):
        return ('mixed provenance formats',)
    if apple and ('source' in manifest or 'files' in manifest):
        return ('mixed provenance formats',)
    source = manifest['source'] if pstack else manifest['upstream']
    integrity = manifest if pstack else manifest['integrity']
    if not isinstance(source, dict) or not isinstance(integrity, dict):
        return ('invalid source or integrity object',)
    if apple and integrity.get('algorithm') != 'sha256':
        return ('unsupported digest algorithm',)
    records = integrity.get('files')
    if not isinstance(records, dict):
        return ('invalid payload records',)
    errors = []
    pin = source.get('commit')
    if not isinstance(pin, str) or not re.fullmatch(pattern=r'[a-f0-9]{40}', string=pin):
        errors.append('invalid recorded upstream SHA-1 format')
    if set(records) != set(payloads):
        errors.append('payload inventory differs from provenance')
    for relative, record in records.items():
        if not isinstance(relative, str) or Path(relative).is_absolute() or '..' in Path(relative).parts or '\\' in relative:
            errors.append('invalid payload path')
            continue
        expected = record.get('sha256') if isinstance(record, dict) else record
        actual = hashlib.sha256(payloads.get(relative, b'')).hexdigest()
        if not digest(value=expected) or expected != actual:
            errors.append(f'payload digest mismatch: {relative}')
        if pstack:
            if not isinstance(record, dict) or not digest(value=record.get('upstream_sha256')):
                errors.append(f'invalid upstream digest: {relative}')
            elif record.get('modified') is not (expected != record['upstream_sha256']):
                errors.append(f'inconsistent modification claim: {relative}')
    if not payloads.get('LICENSE'):
        errors.append('missing or empty LICENSE')
    license_record = records.get('LICENSE')
    original = license_record.get('upstream_sha256') if isinstance(license_record, dict) else source.get('license_sha256')
    actual_license = hashlib.sha256(payloads.get('LICENSE', b'')).hexdigest()
    if not digest(value=original) or original != actual_license:
        errors.append('changed or unrecorded upstream license')
    if source.get('license_sha256', original) != original:
        errors.append('conflicting license digests')
    if not payloads.get('SKILL.md'):
        errors.append('missing or empty SKILL.md')
    return tuple(errors)


def unique_object(*, pairs: list) -> dict:
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f'duplicate JSON key: {key}')
        result[key] = value
    return result


def raise_walk_error(error: OSError) -> None:
    raise error


def inspect(*, directory: Path) -> tuple[str, ...]:
    try:
        if directory.is_symlink() or not directory.is_dir():
            return ('package must be a real directory',)
        paths = []
        for parent, directories, files in os.walk(top=directory, onerror=raise_walk_error):
            paths.extend(Path(parent) / name for name in (*directories, *files))
        if any(path.is_symlink() for path in paths):
            return ('symlink in package',)
        if any(not path.is_file() and not path.is_dir() for path in paths):
            return ('nonregular payload in package',)
        manifest = json.loads(s=directory.joinpath('provenance.json').read_text(encoding='utf-8'), object_pairs_hook=lambda pairs: unique_object(pairs=pairs))
        if not isinstance(manifest, dict):
            return ('provenance must be a JSON object',)
        payloads = {path.relative_to(directory).as_posix(): path.read_bytes()
                    for path in paths if path.is_file() and path != directory / 'provenance.json'}
        return validate(manifest=manifest, payloads=payloads)
    except (OSError, ValueError, TypeError, AttributeError) as error:
        return (f'invalid package: {error}',)


def main() -> int:
    parser = argparse.ArgumentParser(description='Check local worktree skill bytes, inventory and license consistency. No Git tracking, source authentication, invocation or workflow verification is performed. Selected upstream repositories use SHA-1 object IDs.')
    parser.add_argument('--package', type=Path, action='append', required=True)
    options = parser.parse_args()
    failed = False
    for directory in options.package:
        errors = inspect(directory=directory)
        print(f'{directory}: ' + ('; '.join(errors) if errors else 'local payload inventory, digests and license match'))
        failed = failed or bool(errors)
    return int(failed)


if __name__ == '__main__':
    raise SystemExit(main())
