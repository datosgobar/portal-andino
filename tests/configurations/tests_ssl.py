#! coding: utf-8

import unittest
import requests
import nose.tools as nt


class TestSSL(unittest.TestCase):

    def test_ssl_port_returns_response_with_status_200(self):
        req = requests.get('https://localhost:7777', verify=False)
        nt.assert_equals(req.status_code, 200)

    def test_ssl_port_returns_response_with_redirection(self):
        req = requests.get('http://localhost', verify=False)
        nt.assert_true(len(req.history) == 1)
        nt.assert_false(req.history[0].status_code == 301)
