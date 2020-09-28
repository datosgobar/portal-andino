#! coding: utf-8

import subprocess
import nose.tools as nt
from tests import TestPortalAndino


class TestFileSizeLimit(TestPortalAndino.TestPortalAndino):

    @classmethod
    def setUpClass(cls):
        super(TestFileSizeLimit, cls).setUpClass()

    def test_nginx_configuration_uses_1024_MB_as_file_size_limit(self):
        size_line = subprocess.check_output(
            'sudo docker exec -it andino-nginx cat /etc/nginx/conf.d/default.conf | grep client_max_body_size', shell=True)
        nt.assert_true('1024' in size_line)
