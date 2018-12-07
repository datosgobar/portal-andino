#! coding: utf-8

import unittest
import subprocess


class TestPortalAndino(unittest.TestCase):

    def __init__(self, *args):
        super(TestPortalAndino, self).__init__()
        self.nginx_port = ''
        self.nginx_ssl_port = ''

    def setup(self):
        ports = subprocess.check_output('docker port andino-nginx', shell=True).strip().split('\n')
        for port in ports:
            if port.startswith('80'):
                self.nginx_port = port[port.rfind(':'):]
            elif port.startswith('443'):
                self.nginx_ssl_port = port[port.rfind(':'):]

    def runTest(self):
        print "Corriendo tests del portal"
