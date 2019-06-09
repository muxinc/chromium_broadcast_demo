#!/usr/bin/env python3
from flask import Flask, send_from_directory
from flask_sockets import Sockets
import json

app = Flask(__name__)
sockets = Sockets(app)

clients = []
server = None

@sockets.route('/echo')
def echo_socket(ws):
    print("Hey cool a client")
    while not ws.closed:
        msgStr = ws.receive()
        try:
            msg = json.loads(msgStr)
            if msg["type"] == "server_hello":
                server = ws
            elif msg["type"] == "client_hello":
                clients.append(ws)
            elif msg["target"] == "server":
                if server is not None:
                    server.send(msgStr)
                else:
                    print("Warning: received a client message without a server")
            else:
                for client in clients:    
                    if client is not ws:
                        try:
                            client.send(msgStr)
                        except:
                            print("Error: Failed to send message to client")
        except Exception as ex:
            print("Error parsing message: ", msgStr, ex)

    clients.remove(ws)

@app.route('/<path:path>')
def send_static(path):
    return send_from_directory('static', path)


if __name__ == "__main__":
    from gevent import pywsgi
    from geventwebsocket.handler import WebSocketHandler
    server = pywsgi.WSGIServer(('', 5000), app, handler_class=WebSocketHandler)
    server.serve_forever()
