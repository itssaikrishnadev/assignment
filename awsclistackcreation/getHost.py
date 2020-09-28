import socket
from flask import Flask, request

app = Flask(__name__)

@app.route("/hostname/")
def return_hostname():
    return "Hostname of the hosting server is {} and your IP is {}".format(socket.gethostname(), request.remote_addr)

if __name__ == "__main__":
    app.run(host='0.0.0.0')
