#! coding: utf-8

import unittest
import subprocess


class TestPortalAndino(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.nginx_port = ''
        cls.nginx_ssl_port = ''
        ports = subprocess.check_output('docker port andino-nginx', shell=True).strip().split('\n')
        for port in ports:
            if port.startswith('80'):
                cls.nginx_port = port[port.rfind(':')+1:]
            elif port.startswith('443'):
                cls.nginx_ssl_port = port[port.rfind(':')+1:]
