from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route("/health")
def health():
return jsonify(status="Backend is healthy")

@app.route("/api/message")
def message():
return jsonify(message="Hello from Python Backend!")

if __name__ == "__main__":
app.run(host="0.0.0.0", port=5000)
