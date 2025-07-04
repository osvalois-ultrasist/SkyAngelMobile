import json
import os
from flask import Blueprint, request, jsonify
from app.configuraciones.rutas_archivos import archivo_delitos_anidados

# Se crea la coleccion de endpoints                           
json_delitos = Blueprint('json_delitos', __name__)
      
@json_delitos.route("/jsondelitos", methods=["GET"])
def json_delitos_get():
    try:
        # Lee el archivo JSON
        with open(archivo_delitos_anidados, 'r') as file:
            data = json.load(file)
        # Devuelve el contenido del JSON
        return jsonify(data), 200
    except Exception as e:
        return jsonify({"Error": "No se pudo leer el archivo JSON", "Detalles": str(e)}),500
