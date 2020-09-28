#! coding: utf-8

import requests
import nose.tools as nt
from tests import TestPortalAndino


class TestSSL(TestPortalAndino.TestPortalAndino):

    @classmethod
    def setUpClass(cls):
        super(TestSSL, cls).setUpClass()

    def test_ssl_port_returns_response_with_status_200(self):
        req = requests.get('https://{0}:{1}'.format(self.site_url, self.nginx_ssl_port), verify=False)
        nt.assert_equals(req.status_code, 200)

    def test_ssl_port_returns_response_with_redirection(self):
        req = requests.get('http://{0}:{1}'.format(self.site_url, self.nginx_port), verify=False)
        nt.assert_true(len(req.history) == 1)
        nt.assert_true(req.history[0].status_code == 301)
