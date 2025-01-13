from flask import Flask, request, jsonify
from google.cloud import bigtable
from google.cloud.bigtable.row import DirectRow

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Flask running on Cloud Run!"

@app.route('/add_point', methods=['POST'])
def add_point():
    data = request.json
    instance_id = "venezuelalibre-instance"
    table_id = "mapa_puntos"
    cluster_zone = "us-central1-a"

    client = bigtable.Client(admin=True)
    instance = client.instance(instance_id)
    table = instance.table(table_id)

    # Guardar el punto en Bigtable
    row_key = f"{data['lat']}_{data['lng']}"
    row = DirectRow(row_key, table)
    row.set_cell('info', 'url', data['url'].encode('utf-8'))
    row.commit()

    return jsonify({"status": "success", "message": "Point added successfully!"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)