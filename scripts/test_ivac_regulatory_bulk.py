#!/usr/bin/env python3
import io
import json
from pathlib import Path
import tempfile
from unittest.mock import patch
import unittest
import zipfile
import ivac_regulatory_bulk as bulk

XML = b'<LegislativeDocument xml:lang="fr"><Regulation><Identification><Id>P-9.2.1, r. 1</Id></Identification><Section Code="se:25" date-eev="20211013"><Text>SYNTHETIC NOT LAW</Text></Section></Regulation></LegislativeDocument>'


def archive(members):
    b = io.BytesIO()
    with zipfile.ZipFile(b, 'w') as z:
        for name, data in members: z.writestr(name, data)
    return b.getvalue()


class BulkTests(unittest.TestCase):
    def test_actual_separator_shape_and_determinism(self):
        data = archive([('Regulations\\P-9.2.1,R.1\\FR\\P-9.2.1,R.1_FR.xml', XML)])
        a = bulk.select_members(data, 'P-9.2.1, r. 1')
        self.assertEqual(a, bulk.select_members(data, 'P-9.2.1, r. 1'))
        self.assertEqual(a[1], XML)
        self.assertEqual(a[0]['legalEffect'], 'not-determined')
        self.assertEqual(a[0]['consolidationDate'], 'unknown')

    def test_unsafe_and_duplicate_zip(self):
        for names in [('../x.xml',), ('C:\\x.xml',), ('/x.xml',), ('x.xml','X.xml'), ('a\\x.xml','a/x.xml')]:
            with self.subTest(names=names), self.assertRaises(ValueError):
                bulk.inspect_zip(archive([(n,XML) for n in names]))
        symlink = zipfile.ZipInfo('link.xml'); symlink.external_attr = (0o120777 << 16)
        with self.assertRaises(ValueError): bulk.inspect_zip(archive([(symlink, b'target')]))

    def test_missing_duplicate_and_wrong_identity(self):
        for data in [archive([('other.xml',XML)]), archive([('P-9.2.1,R.1_FR.xml',XML),('other/P-9.2.1,R.1_FR.xml',XML)]),
                     archive([('P-9.2.1,R.1_FR.xml',XML.replace(b'P-9.2.1, r. 1',b'WRONG'))])]:
            with self.assertRaises(ValueError): bulk.select_members(data, 'P-9.2.1, r. 1')

    def test_xml_security_and_structure(self):
        for xml in [b'<!DOCTYPE x [<!ENTITY e SYSTEM "file:///etc/passwd">]><x>&e;</x>', b'<wrong/>',
                    XML.replace(b'</Regulation>',b'<Section Code="se:25"/></Regulation>')]:
            with self.assertRaises(Exception): bulk.xml_observation(xml, 'P-9.2.1, r. 1')

    def test_reacquisition_integrity_and_missing_bytes(self):
        # A complete mocked catalogue exercises metadata, CUE validation and
        # exact-byte verification without depending on official network uptime.
        resources = [{'id': str(i), 'name': name, 'url': 'https://www.donneesquebec.ca/' + str(i)}
                     for i, name in enumerate(['Lois', 'Règlements', 'Liste des lois et des règlements en français'])]
        catalog = json.dumps({'success': True, 'result': {'id':bulk.DATASET, 'license_id':'synthetic',
                              'license_url':'https://example.invalid/license','resources':resources}}).encode()
        def fetch(url):
            if url == bulk.CATALOG_URL: return catalog
            if url.endswith('/2'): return b'SYNTHETIC INDEX'
            xml = XML.replace(b'P-9.2.1, r. 1',b'P-9.2.1') if url.endswith('/0') else XML
            name = 'P-9.2.1_FR.xml' if url.endswith('/0') else 'P-9.2.1,R.1_FR.xml'
            return archive([(name,xml)])
        with tempfile.TemporaryDirectory() as temp, patch.object(bulk,'fetch',side_effect=fetch):
            directory = Path(temp)/'acquisition'
            report = bulk.acquire(directory)
            self.assertEqual(report['gaps'],[])
            self.assertEqual(bulk.verify(directory),report)
            xml = directory/'regulation.xml'
            original = xml.read_bytes();xml.write_bytes(original+b'tamper')
            with self.assertRaises(ValueError): bulk.verify(directory)
            xml.write_bytes(original)
            artifact=directory/'1';original=artifact.read_bytes();artifact.write_bytes(b'tamper')
            with self.assertRaises(ValueError): bulk.verify(directory)
            artifact.unlink()
            with self.assertRaises(FileNotFoundError): bulk.verify(directory)

    def test_limits_and_no_xml(self):
        with self.assertRaises(ValueError): bulk.inspect_zip(archive([('note.txt',b'no XML')]))
        old = bulk.MAX_EXPANDED
        try:
            bulk.MAX_EXPANDED = 1
            with self.assertRaises(ValueError): bulk.inspect_zip(archive([('x.xml',XML)]))
        finally: bulk.MAX_EXPANDED = old


if __name__ == '__main__': unittest.main(verbosity=2)
