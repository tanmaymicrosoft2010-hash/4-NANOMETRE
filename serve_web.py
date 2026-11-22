import http.server
import socketserver
import os
import sys

DIRECTORY = os.path.join(os.path.dirname(__file__), "build", "web")
PORT = 8080

class GodotHTTPHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # Enable Cross-Origin Isolation for high-performance WebAssembly & Web Audio
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()

    def guess_type(self, path):
        if path.endswith(".wasm"):
            return "application/wasm"
        if path.endswith(".pck"):
            return "application/octet-stream"
        if path.endswith(".js"):
            return "application/javascript"
        return super().guess_type(path)


def run():
    socketserver.TCPServer.allow_reuse_address = True
    for port in [8080, 8000, 8888, 5000, 3000]:
        try:
            with socketserver.TCPServer(("127.0.0.1", port), GodotHTTPHandler) as httpd:
                print(f"SERVING_ON:http://127.0.0.1:{port}/", flush=True)
                httpd.serve_forever()
                break
        except OSError:
            continue

if __name__ == "__main__":
    run()
