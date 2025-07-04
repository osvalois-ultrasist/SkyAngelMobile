'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_delitos_secretariado_municipio import Delitos_secretariado_municipio_service                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
delsecmun = Blueprint('delsecmun', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@delsecmun.route("/delitos_secretariado_mun",methods=["POST"])
def delitos_sec_mun_post():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = Delitos_secretariado_municipio_service().insert(data)
        return response, status_code

@delsecmun.route("/delitos_secretariado_mun/<int:id_delito_municipio>", methods=["PUT", "DELETE"])
def delitos_sec_mun_id(id_delito_municipio):
    if request.method == 'PUT':
        data = request.get_json()
        response, status_code = Delitos_secretariado_municipio_service().update(id_delito_municipio, data)
        return response, status_code

    elif request.method == 'DELETE':
        response, status_code = Delitos_secretariado_municipio_service().delete(id_delito_municipio)
        return response, status_code 

@delsecmun.route("/delitos_secretariado_mun", methods=["GET"])
def delitos_sec_mun_get():
    if request.method == 'GET':
        response, status_code = Delitos_secretariado_municipio_service().select_all()
        return response, status_code