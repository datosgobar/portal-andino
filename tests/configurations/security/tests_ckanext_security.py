#! coding: utf-8

import nose.tools as nt
import subprocess
from tests import TestPortalAndino


class TestCkanextSecurity(TestPortalAndino.TestPortalAndino):

    def test_successful_plugin_enablement_and_disablement(self):
        security_path = "/etc/ckan_init.d/security/"
        enablement_script = "enable_ckanext_security.sh"
        disablement_script = "disable_ckanext_security.sh"

        # Enable
        subprocess.check_call(
            "docker exec -it andino {0}./{1}".format(security_path, enablement_script), shell=True)
        cmd = "grep '## ckanext-security' /etc/ckan/default/production.ini"
        search_result = subprocess.check_output("docker exec -it andino {}".format(cmd), shell=True).strip()
        nt.assert_equal("## ckanext-security", search_result)

        # Disable
        subprocess.check_call(
            "docker exec -it andino {0}./{1}".format(security_path, disablement_script), shell=True)
        cmd = "{} || true".format(cmd)
        search_result = subprocess.check_output("docker exec -it andino {}".format(cmd), shell=True).strip()
        nt.assert_equal("", search_result)
