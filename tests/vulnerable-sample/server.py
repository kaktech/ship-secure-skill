#!/usr/bin/env python3
"""Tiny insecure HTTP server for testing scripts/check-headers.sh. Binds to localhost only."""
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer


class H(BaseHTTPRequestHandler):
    server_version = "Apache/2.2.8"          # banner leak
    sys_version = ""

    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.send_header("X-Powered-By", "PHP/5.2.0")
        self.send_header("Set-Cookie", "sid=abc123; Path=/")   # no HttpOnly/Secure/SameSite
        self.end_headers()
        self.wfile.write(b"<h1>vulnerable-sample</h1>")

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8099
    HTTPServer(("127.0.0.1", port), H).serve_forever()
