from flask import Blueprint, jsonify
from app.controladores.fun_punto_ferroviarios import Punto_ferroviarios_service
# Se crea la coleccion de endpoints
punto_ferroviarios = Blueprint('punto_ferroviarios', __name__)

# Esta función regresa un geojson de los puntos ferroviarios
@punto_ferroviarios.route("/punto_interes/ferroviarios",methods=["GET"])
def punto_ferroviarios_get():
    try:
        response, status_code = Punto_ferroviarios_service().obtener_GeoJson()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response