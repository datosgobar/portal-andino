#! coding: utf-8

import unittest
import requests
import nose.tools as nt


class TestBaseConfig(unittest.TestCase):

    def test_cache_miss(self):
        req = requests.get('http://localhost', verify=False)
        cache_status = req.headers.get('X-Cache-Status', '')
        nt.assert_true(not cache_status or cache_status == 'MISS')

    def test_ssl_port_returns_response_with_status_200(self):
        req = requests.get('http://localhost', verify=False)
        nt.assert_equals(req.status_code, 200)
