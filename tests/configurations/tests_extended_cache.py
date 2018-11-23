#! coding: utf-8

import unittest
import requests
import nose.tools as nt


class TestExtendedCache(unittest.TestCase):

    def test_cache_hit_with_extended_cache(self):
        requests.get('http://localhost', verify=False)
        req = requests.get('http://localhost', verify=False)
        nt.assert_true(req.headers.get('X-Cache-Status', '') == 'HIT')
