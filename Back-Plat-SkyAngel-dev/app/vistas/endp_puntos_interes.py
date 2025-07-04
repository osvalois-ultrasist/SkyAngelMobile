from flask import Blueprint, jsonify
from app.controladores.fun_puntos_interes import Puntos_interes_service

# Se crea la colección de endpoints
punto_interes = Blueprint('punto_interes', __name__)

# Esta función regresa el geojson de los puntos de interes incidencias_delictivas
@punto_interes.route("/punto_interes/incidencias", methods=["GET"])
def incidencias_get():
    try:
        response, status_code = Puntos_interes_service().select_incidencias()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response
    
# Esta función regresa el geojson de los puntos de interes otras_incidencias
@punto_interes.route("/punto_interes/otras_incidencias", methods=["GET"])
def otras_incidencias_get():
    try:
        response, status_code = Puntos_interes_service().select_otras_incidencias()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response
    
# Esta función regresa el geojson de los puntos de interes accidentes
@punto_interes.route("/punto_interes/accidentes", methods=["GET"])
def accidentes_get():
    try:
        response, status_code = Puntos_interes_service().select_accidentes()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response

# Esta función regresa el geojson de los puntos de interes recuperaciones
@punto_interes.route("/punto_interes/recuperacion", methods=["GET"])
def recuperacion_get():
    try:
        response, status_code = Puntos_interes_service().select_recuperaciones()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response
    
# Esta función regresa el geojson de los puntos de interes paraderos
@punto_interes.route("/punto_interes/paraderos", methods=["GET"])
def paraderos_get():
    try:
        response, status_code = Puntos_interes_service().select_paraderos()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response

# Esta función regresa el geojson de los puntos de interes cachimbas
@punto_interes.route("/punto_interes/cachimbas", methods=["GET"])
def cachimbas_get():
    try:
        response, status_code = Puntos_interes_service().select_cachimbas()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response

# Esta función regresa el geojson de los puntos de interes casetas
@punto_interes.route("/punto_interes/casetas", methods=["GET"])
def casetas_get():    
    try:
        response, status_code = Puntos_interes_service().select_casetas()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response
    
# Esta función regresa el geojson de los puntos de interes corralones
@punto_interes.route("/punto_interes/corralones", methods=["GET"])
def corralones_get():
    try:
        response, status_code = Puntos_interes_service().select_corralones()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response
    
# Esta función regresa el geojson de los puntos de interes ministerios publicos
@punto_interes.route("/punto_interes/ministerios", methods=["GET"])
def ministerios_get():
    try:
        response, status_code = Puntos_interes_service().select_ministerios()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response

# Esta función regresa el geojson de los puntos de interes guardia nacional
@punto_interes.route("/punto_interes/guardia", methods=["GET"])
def guardia_get():
    try:
        response, status_code = Puntos_interes_service().select_guardia()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response

# Esta función regresa el geojson de los puntos de interes pensiones
@punto_interes.route("/punto_interes/pensiones", methods=["GET"])
def pensiones_get():
    try:
        response, status_code = Puntos_interes_service().select_pensiones()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response

# Esta función regresa el geojson de los puntos de interes cobertura
@punto_interes.route("/punto_interes/cobertura", methods=["GET"])
def cobertura_get():
    try:
        response, status_code = Puntos_interes_service().select_cobertura()
        return response, status_code
    except:
        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response

