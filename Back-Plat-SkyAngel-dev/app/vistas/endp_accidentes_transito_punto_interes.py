from flask import Blueprint, jsonify
from app.controladores.fun_accidentes_transito_punto_interes import *  # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
accidentes_transito_punto_interes = Blueprint('accidentes_transito_punto_interes', __name__)        

@accidentes_transito_punto_interes.route("/punto_interes/accidentes_transito", methods=["GET"])
def accidentes_transito_get():
    try:
        response = select_accidentes_transito()
        return response
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response