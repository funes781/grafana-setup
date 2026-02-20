from flask import Flask, request, jsonify
from prometheus_client import Gauge, generate_latest, CONTENT_TYPE_LATEST
import os
import sys

app = Flask(__name__)

API_TOKEN = os.getenv("API_TOKEN")
DYNAMIC_METRICS = {}

@app.route('/log', methods=['POST'])
def receive_log():
    auth = request.headers.get('Authorization')
    if not auth or auth != f"Bearer {API_TOKEN}":
        return jsonify({"error": "unauthorized"}), 401

    try:
        data = request.get_json(force=True)
        
        if not data:
            return jsonify({"status": "empty"}), 200

        for key, value in data.items():
            try:
                val = float(value)
                m_name = f"fivem_{key}"
                if m_name not in DYNAMIC_METRICS:
                    DYNAMIC_METRICS[m_name] = Gauge(m_name, f'Metric {key}')
                DYNAMIC_METRICS[m_name].set(val)
            except (ValueError, TypeError):
        
        return jsonify({"status": "ok"}), 200
    except Exception as e:
        print(f"CRITICAL ERROR: {e}", file=sys.stderr)
        return jsonify({"error": str(e)}), 400

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)