#! coding: utf-8

import requests
import nose.tools as nt
from tests import TestPortalAndino


class TestSSL(TestPortalAndino.TestPortalAndino):

    def setup(self):
        super(TestSSL, self).setup()

    def test_ssl_port_returns_response_with_status_200(self):
        req = requests.get('https://localhost:{}'.format(self.nginx_ssl_port), verify=False)
        nt.assert_equals(req.status_code, 200)

    def test_ssl_port_returns_response_with_redirection(self):
        req = requests.get('http://localhost:{}'.format(self.nginx_port), verify=False)
        nt.assert_true(len(req.history) == 1)
        nt.assert_true(req.history[0].status_code == 301)
