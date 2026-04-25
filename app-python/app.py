from http.server import HTTPServer, BaseHTTPRequestHandler

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b"<html><body><h1>Hello from container! (Python)</h1></body></html>")

if __name__ == '__main__':
    port = 8080
    server = HTTPServer(('', port), SimpleHandler)
    print(f"Servidor funcionant al port {port}...")
    server.serve_forever()
