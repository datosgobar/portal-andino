#! coding: utf-8

import requests
import nose.tools as nt
from tests import TestPortalAndino


class TestExtendedCache(TestPortalAndino.TestPortalAndino):

    @classmethod
    def setUpClass(cls):
        super(TestExtendedCache, cls).setUpClass()

    def test_cache_hit_with_extended_cache(self):
        requests.get('http://localhost:{}'.format(self.nginx_port), verify=False)
        req = requests.get('http://localhost:{}'.format(self.nginx_port), verify=False)
        nt.assert_true(req.headers.get('X-Cache-Status', '') == 'HIT')
