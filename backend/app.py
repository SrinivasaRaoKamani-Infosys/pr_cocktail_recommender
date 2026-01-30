# app.py
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/health", methods=["GET"])
def health():
    return jsonify(status="Backend is healthy"), 200

@app.route("/", methods=["GET"])
def root():
    return jsonify(message="Backend running"), 200

if __name__ == "__main__":
    # Azure Container Apps backend target_port is 5000
    app.run(host="0.0.0.0", port=5000)
