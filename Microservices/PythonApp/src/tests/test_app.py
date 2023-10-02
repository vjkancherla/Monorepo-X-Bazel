import unittest
import os
from unittest.mock import patch
from http.server import HTTPServer
from requests import get
import threading

from Microservices.PythonApp.src.app import app


class TestMyHandler(unittest.TestCase):
    def setUp(self):
        self.server_address = ('', 8888)
        self.httpd = HTTPServer(self.server_address, app.MyHandler)
        self.server_thread = threading.Thread(target=self.httpd.serve_forever)
        self.server_thread.setDaemon(True)
        self.server_thread.start()

    def tearDown(self):
        self.httpd.shutdown()
        self.server_thread.join()

    @patch('os.getenv')
    def test_handler(self, mock_getenv):
        mock_getenv.side_effect = ['dev', '1.0', 'test message']

        response = get('http://localhost:8888')

        self.assertEqual(response.status_code, 200)
        self.assertIn('Environment: dev', response.text)
        self.assertIn('Image_version: 1.0', response.text)
        self.assertIn('Custom_Message: test message', response.text)


if __name__ == '__main__':
    unittest.main()
