from http.server import BaseHTTPRequestHandler, HTTPServer
import os

environment   = os.getenv('ENVIRONMENT', 'dev')   # Default to 'dev' if not set
image_version = os.getenv('IMAGE_VERSION', '1.0')  # Default to '1.0' if not set
message       = os.getenv('MESSAGE', 'test message')       # Default to 'test message' if not set

class MyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'''
          ##         .
    ## ## ##        ==
 ## ## ## ## ##    ===
/"""""""""""""""""\___/ ===
{                       /  ===-
\______ O           __/
 \    \         __/
  \____\_______/


Hello from Docker!
''')
        self.wfile.write(bytes('Environment: ' + environment + ', Image_version: ' + image_version + ', Custom_Message: ' + message, encoding='utf8'))

def run(): # pragma: no cover
    server_address = ('', 8888)
    httpd = HTTPServer(server_address, MyHandler)
    httpd.serve_forever()

if __name__ == '__main__':
    run()
