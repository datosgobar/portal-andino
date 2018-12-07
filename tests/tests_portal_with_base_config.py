#! coding: utf-8

import requests
import nose.tools as nt
from tests import TestPortalAndino


class TestBaseConfig(TestPortalAndino.TestPortalAndino):

    @classmethod
    def setUpClass(cls):
        super(TestBaseConfig, cls).setUpClass()

    def test_cache_miss(self):
        req = requests.get('http://localhost:{}'.format(self.nginx_port), verify=False)
        cache_status = req.headers.get('X-Cache-Status', '')
        nt.assert_true(not cache_status or cache_status == 'MISS')

    def test_http_port_returns_response_with_status_200(self):
        req = requests.get('http://localhost:{}'.format(self.nginx_port), verify=False)
        nt.assert_equals(req.status_code, 200)
