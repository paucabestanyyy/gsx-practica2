import os
from http.server import HTTPServer, BaseHTTPRequestHandler

# Llegim la variable d'entorn injectada per Docker Compose
MESSAGE = os.getenv('WELCOME_MESSAGE', 'Missatge per defecte')
PORT = int(os.getenv('APP_PORT', 8080))

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Aquesta ruta oculta la farà servir el "Healthcheck" per saber si estem vius
        if self.path == '/health':
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
            return
            
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(f"<html><body><h1>{MESSAGE}</h1></body></html>".encode('utf-8'))

if __name__ == '__main__':
    server = HTTPServer(('', PORT), SimpleHandler)
    print(f"Backend escoltant al port {PORT}...")
    server.serve_forever()
