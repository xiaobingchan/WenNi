import json
from flask import Flask, request
app = Flask(__name__)
@app.route('/')
def hello():
    header = {}
    header["REMOTE_ADDR"] = request.headers["REMOTE_ADDR"]
    header["HTTP_VIA"] = request.headers["HTTP_VIA"]
    header["HTTP_X_FORWARDED_FOR"] = request.headers["HTTP_X_FORWARDED_FOR"]
    return json.dumps(header)
if __name__ == '__main__':
    app.run(port=5000,debug=True)