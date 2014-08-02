import os
import json
import shutil
import tempfile
import unittest
from jterator.runner import JteratorRunner


FOO_PIPE = os.path.join(os.path.dirname(__file__),
                        'mock', 'foo_example')


class TestFoo(unittest.TestCase):

    def setUp(self):
        # Build a mock pipeline.
        self.pipe_path = os.path.join(tempfile.mkdtemp(), 'foo')
        shutil.copytree(src=FOO_PIPE, dst=self.pipe_path)
        #os.makedirs(os.path.join(self.pipe_path, 'logs'))
        # Instantiate a runner
        self.jt = JteratorRunner(self.pipe_path)

    def test_runner_instantion(self):
        self.jt.build_pipeline()
        assert len(self.jt.modules) > 0
        self.jt.run_pipeline()
