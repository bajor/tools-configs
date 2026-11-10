import hashlib
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(name='verify_skill_package', location=Path(__file__).resolve().parents[1] / 'scripts/verify_skill_package.py')
audit = importlib.util.module_from_spec(spec=spec)
spec.loader.exec_module(module=audit)


class PackageIntegrityTests(unittest.TestCase):
    def test_detects_changed_missing_and_uninventoried_payload(self):
        license_bytes = b'MIT required notice\n'
        skill_bytes = b'---\nname: fixture\n---\n'
        digest = hashlib.sha256(license_bytes).hexdigest()
        manifest = {'source': {'commit': 'a' * 40}, 'files': {
            'LICENSE': {'sha256': digest, 'upstream_sha256': digest},
            'SKILL.md': {'sha256': hashlib.sha256(skill_bytes).hexdigest()}}}
        good = {'LICENSE': license_bytes, 'SKILL.md': skill_bytes}
        self.assertEqual(first=audit.validate(manifest=manifest, payloads=good), second=())
        for invalid in [dict(good, **{'SKILL.md': b'changed'}),
                        {'LICENSE': license_bytes}, dict(good, extra=b'hidden')]:
            with self.subTest(payloads=tuple(invalid)):
                self.assertTrue(expr=audit.validate(manifest=manifest, payloads=invalid))
        changed_notice = dict(good, LICENSE=b'deleted notice')
        self.assertTrue(expr=audit.validate(manifest=manifest, payloads=changed_notice))

    def test_supports_apple_inventory_and_rejects_missing_license(self):
        payloads = {'SKILL.md': b'skill', 'LICENSE': b'license'}
        hashes = {name: hashlib.sha256(data).hexdigest() for name, data in payloads.items()}
        manifest = {'upstream': {'commit': 'b' * 40, 'license_sha256': hashes['LICENSE']},
                    'integrity': {'files': hashes}}
        self.assertEqual(first=audit.validate(manifest=manifest, payloads=payloads), second=())
        invalid = {'upstream': {'commit': 'b' * 40}, 'integrity': {'files': hashes}}
        self.assertTrue(expr=audit.validate(manifest=invalid, payloads=payloads))

    def test_invalid_manifest_and_symlink_cannot_pass(self):
        with tempfile.TemporaryDirectory(prefix='skill-audit-') as temporary:
            directory = Path(temporary)
            directory.joinpath('provenance.json').write_text(data='[]', encoding='utf-8')
            self.assertTrue(expr=audit.inspect(directory=directory))
            directory.joinpath('provenance.json').write_text(data=json.dumps({'source': {'commit': 'main'}}), encoding='utf-8')
            self.assertTrue(expr=audit.inspect(directory=directory))
            directory.joinpath('nested').mkdir()
            directory.joinpath('nested/provenance.json').write_text(data='{}', encoding='utf-8')
            self.assertTrue(expr=audit.inspect(directory=directory))
            directory.joinpath('SKILL.md').symlink_to(target=directory / 'provenance.json')
            self.assertEqual(first=audit.inspect(directory=directory), second=('symlink in package',))


if __name__ == '__main__':
    unittest.main()
