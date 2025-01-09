from google.cloud import firestore

# Inicializar cliente de Firestore
db = firestore.Client()

# Datos de prueba
markers = [
    {"lat": 10.4806, "lng": -66.9036, "title": "Caracas", "content": "Capital de Venezuela"},
    {"lat": 10.3910, "lng": -71.4382, "title": "Maracaibo", "content": "Ciudad petrolera"},
    {"lat": 8.591, "lng": -70.2484, "title": "Mérida", "content": "Ciudad andina"}
]

# Agregar marcadores a Firestore
for marker in markers:
    doc_ref = db.collection("markers").add(marker)
    print(f"Marcador agregado: {marker}")
