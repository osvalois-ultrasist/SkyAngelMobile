import json
from app.configuraciones.rutas_archivos import archivo_tweets

def leer_tweets():
    try:
        with open(archivo_tweets) as f:
            return json.load(f)
    except:
        return []

def guardar_tweets(nuevos_tweets):
    with open(archivo_tweets, "w") as f:
        json.dump(nuevos_tweets, f, indent=2)
