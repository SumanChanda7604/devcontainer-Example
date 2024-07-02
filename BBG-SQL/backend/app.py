# backend/app.py
from flask import Flask, request, jsonify
from db_utils import get_db_schema
import os
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.DEBUG)

@app.route('/get-schema', methods=['POST'])
def get_schema():
    data = request.get_json()
    db_name = data['db_name']
    
    try:
        schema = get_db_schema(db_name)
        return jsonify(schema)
    except Exception as e:
        app.logger.error(f"Error getting schema for {db_name}: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8082)
