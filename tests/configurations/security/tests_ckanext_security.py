#! coding: utf-8

import nose.tools as nt
import subprocess
from tests import TestPortalAndino


class TestCkanextSecurity(TestPortalAndino.TestPortalAndino):

    def __init__(self):
        super(TestCkanextSecurity, self).__init__()
        self.security_path = "/etc/ckan_init.d/security/"
        self.enablement_script = "enable_ckanext_security.sh"
        self.disablement_script = "disable_ckanext_security.sh"

    def test_successful_plugin_enablement_and_disablement(self):
        # Enable
        subprocess.check_call(
            "docker exec -it andino {0}./{1}".format(self.security_path, self.enablement_script), shell=True)
        cmd = "grep 'ckan.site_url = https://localhost' /etc/ckan/default/production.ini"
        search_result = subprocess.check_output("docker exec -it andino {}".format(cmd)).strip()
        nt.assert_equal("## ckanext-security", search_result)

        # Disable
        subprocess.check_call(
            "docker exec -it andino {0}./{1}".format(self.security_path, self.disablement_script), shell=True)
        cmd = "{} || true".format(cmd)
        search_result = subprocess.check_output("docker exec -it andino {}".format(cmd)).strip()
        nt.assert_equal("", search_result)
