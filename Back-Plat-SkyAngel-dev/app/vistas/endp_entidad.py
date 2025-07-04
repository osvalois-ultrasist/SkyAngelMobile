'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_entidad import Entidad_service                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
entidad = Blueprint('entidad', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@entidad.route("/entidad",methods=["POST"])
def entidad_post():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = Entidad_service().insert(data)
        return response, status_code

@entidad.route("/entidad/<int:id_entidad>", methods=["PUT", "DELETE"])
def entidad_id(id_entidad):
    if request.method == 'PUT':
        data = request.get_json()
        response, status_code = Entidad_service().update(id_entidad, data)
        return response, status_code

    elif request.method == 'DELETE':
        response, status_code = Entidad_service().delete(id_entidad)
        return response, status_code 

@entidad.route("/entidad", methods=["GET"])
def entidad_get():
    if request.method == 'GET':
        response, status_code = Entidad_service().select_all()
        return response, status_code