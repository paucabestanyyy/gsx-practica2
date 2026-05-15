"""Simple HTTP server per a la W8 de GSX (GreenDevCorp).

Respon a tot amb 'Hello from container' i exposa un endpoint /health
per als probes de Kubernetes i healthchecks de Docker.
"""
import os
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = int(os.getenv('APP_PORT', '8080'))


class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'OK')
            return

        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(
            b"<html><body><h1>Hello from container! (Python)</h1></body></html>"
        )

    def log_message(self, format, *args):
        # Logs estructurats per al pipeline d'observability
        print(f"[{self.address_string()}] {format % args}", flush=True)


if __name__ == '__main__':
    server = HTTPServer(('', PORT), SimpleHandler)
    print(f"Servidor funcionant al port {PORT}...", flush=True)
    server.serve_forever()
