#! coding: utf-8

import unittest
import subprocess
import nose.tools as nt


class TestSupervisor(unittest.TestCase):

    def test_supervisor_workers_are_running(self):
        status = subprocess.check_output('sudo docker exec -it andino supervisorctl status', shell=True).strip().split('\n')
        for worker_status in status:
            nt.assert_true(' RUNNING ' in worker_status)
            nt.assert_true(' FATAL ' not in worker_status)
