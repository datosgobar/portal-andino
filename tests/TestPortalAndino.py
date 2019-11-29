#! coding: utf-8

import unittest
import subprocess
from urlparse import urlparse


class TestPortalAndino(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.nginx_port = ''
        cls.nginx_ssl_port = ''
        cls.site_url = cls.get_site_host()
        ports = subprocess.check_output('sudo docker port andino-nginx', shell=True).strip().split('\n')
        for port in ports:
            if port.startswith('80'):
                cls.nginx_port = port[port.rfind(':')+1:]
            elif port.startswith('443'):
                cls.nginx_ssl_port = port[port.rfind(':')+1:]

    @classmethod
    def get_site_host(self):
        current_url = subprocess.check_output(
            'sudo docker exec -it andino grep -E "^ckan.site_url[[:space:]]*=[[:space:]]*" '
            '/etc/ckan/default/production.ini | tr -d [[:space:]]', shell=True).strip()
        current_url = current_url.replace('ckan.site_url', '')[1:]
        return urlparse(current_url).hostname
