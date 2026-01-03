import http.server
import socketserver
import subprocess

PORT = 8888

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        
        # Get usage info
        disk = subprocess.check_output(["df", "-h"]).decode("utf-8")
        memory = subprocess.check_output(["free", "-m"]).decode("utf-8")
        
        html = f"""
        <html>
        <head><title>System Monitor</title></head>
        <body>
            <h1>Infrastructure Monitor</h1>
            <h2>Disk Usage</h2>
            <pre>{disk}</pre>
            <h2>Memory Usage</h2>
            <pre>{memory}</pre>
        </body>
        </html>
        """
        self.wfile.write(html.encode('utf-8'))

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Monitor serving at port {PORT}")
    httpd.serve_forever()
