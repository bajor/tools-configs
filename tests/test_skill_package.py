import copy
import hashlib
import importlib.util
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(name='verify_skill_package', location=Path(__file__).resolve().parents[1] / 'scripts/verify_skill_package.py')
audit = importlib.util.module_from_spec(spec=spec)
spec.loader.exec_module(module=audit)


def package(*, apple: bool = False) -> tuple[dict, dict]:
    payloads = {'SKILL.md': b'---\nname: fixture\n---\n', 'LICENSE': b'MIT notice\n'}
    hashes = {name: hashlib.sha256(data).hexdigest() for name, data in payloads.items()}
    source = {'commit': 'a' * 40}
    if apple:
        manifest = {'schema_version': 1, 'upstream': dict(source, license_sha256=hashes['LICENSE']),
                    'integrity': {'algorithm': 'sha256', 'files': hashes}}
    else:
        records = {name: {'sha256': digest, 'upstream_sha256': digest, 'modified': False} for name, digest in hashes.items()}
        manifest = {'schema_version': 1, 'source': source, 'files': records}
    return manifest, payloads


def write_package(*, directory: Path) -> None:
    manifest, payloads = package()
    directory.joinpath('provenance.json').write_text(data=json.dumps(manifest), encoding='utf-8')
    for name, data in payloads.items():
        directory.joinpath(name).write_bytes(data=data)


class PackageIntegrityTests(unittest.TestCase):
    def test_valid_formats_and_changed_missing_extra_payload(self):
        for apple in (False, True):
            manifest, payloads = package(apple=apple)
            self.assertEqual(first=audit.validate(manifest=manifest, payloads=payloads), second=())
            for invalid in [dict(payloads, **{'SKILL.md': b'changed'}), {'LICENSE': payloads['LICENSE']}, dict(payloads, extra=b'concealed')]:
                self.assertTrue(expr=audit.validate(manifest=manifest, payloads=invalid))

    def test_license_changes_cannot_be_hidden_by_updated_local_hash(self):
        manifest, payloads = package()
        payloads['LICENSE'] = b'edited notice'
        manifest['files']['LICENSE']['sha256'] = hashlib.sha256(payloads['LICENSE']).hexdigest()
        manifest['files']['LICENSE']['modified'] = True
        manifest['source']['license_sha256'] = manifest['files']['LICENSE']['sha256']
        self.assertIn(member='changed or unrecorded upstream license', container=audit.validate(manifest=manifest, payloads=payloads))
        manifest, payloads = package(apple=True)
        payloads.pop('LICENSE')
        manifest['integrity']['files'].pop('LICENSE')
        manifest['upstream']['license_sha256'] = hashlib.sha256(b'').hexdigest()
        self.assertIn(member='missing or empty LICENSE', container=audit.validate(manifest=manifest, payloads=payloads))

    def test_pin_schema_algorithm_and_modification_claims_fail_independently(self):
        good, payloads = package()
        invalid = copy.deepcopy(good)
        invalid['source']['commit'] = 'main'
        self.assertIn(member='invalid recorded upstream SHA-1 format', container=audit.validate(manifest=invalid, payloads=payloads))
        invalid = copy.deepcopy(good)
        invalid['schema_version'] = 2
        self.assertTrue(expr=audit.validate(manifest=invalid, payloads=payloads))
        invalid = copy.deepcopy(good)
        invalid['integrity'] = 'mixed'
        self.assertTrue(expr=audit.validate(manifest=invalid, payloads=payloads))
        invalid = copy.deepcopy(good)
        invalid['files']['SKILL.md']['upstream_sha256'] = 'b' * 64
        self.assertTrue(expr=audit.validate(manifest=invalid, payloads=payloads))
        invalid, payloads = package(apple=True)
        invalid['integrity']['algorithm'] = 'md5'
        self.assertTrue(expr=audit.validate(manifest=invalid, payloads=payloads))
        invalid, payloads = package(apple=True)
        payloads.pop('SKILL.md')
        invalid['integrity']['files'].pop('SKILL.md')
        self.assertIn(member='missing or empty SKILL.md', container=audit.validate(manifest=invalid, payloads=payloads))

    def test_filesystem_rejects_nested_omissions_symlinks_and_special_files(self):
        with tempfile.TemporaryDirectory(prefix='skill-audit-') as temporary:
            directory = Path(temporary)
            write_package(directory=directory)
            self.assertEqual(first=audit.inspect(directory=directory), second=())
            directory.joinpath('nested').mkdir()
            nested = directory / 'nested/provenance.json'
            nested.write_text(data='{}', encoding='utf-8')
            self.assertIn(member='payload inventory differs from provenance', container=audit.inspect(directory=directory))
            nested.unlink()
            directory.joinpath('link').symlink_to(target=directory / 'SKILL.md')
            self.assertEqual(first=audit.inspect(directory=directory), second=('symlink in package',))
            directory.joinpath('link').unlink()
            os.mkfifo(path=directory / 'fifo')
            self.assertEqual(first=audit.inspect(directory=directory), second=('nonregular payload in package',))
        with tempfile.TemporaryDirectory(prefix='skill-root-') as temporary:
            root = Path(temporary)
            root.joinpath('link').symlink_to(target=root, target_is_directory=True)
            self.assertEqual(first=audit.inspect(directory=root / 'link'), second=('package must be a real directory',))

    def test_duplicate_json_and_unreadable_inventory_are_reported_as_failures(self):
        with tempfile.TemporaryDirectory(prefix='skill-errors-') as temporary:
            directory = Path(temporary)
            write_package(directory=directory)
            p = directory / 'provenance.json'
            p.write_text(data='{"schema_version":1,"schema_version":2}', encoding='utf-8')
            self.assertIn(member='duplicate JSON key', container=' '.join(audit.inspect(directory=directory)))
            write_package(directory=directory)
            with patch(target='os.scandir', side_effect=PermissionError('unreadable inventory')):
                self.assertIn(member='unreadable inventory', container=' '.join(audit.inspect(directory=directory)))


if __name__ == '__main__':
    unittest.main()
