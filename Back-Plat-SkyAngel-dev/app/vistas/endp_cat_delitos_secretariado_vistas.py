'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_cat_delitos_secretariado import Cat_modalidad_service                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
cat_delitos_sec = Blueprint('cat_delitos_sec', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@cat_delitos_sec.route("/delitos_secretariado",methods=["POST"])
def cat_delitos_sec_post():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = Cat_modalidad_service().insert(data)
        return response, status_code

@cat_delitos_sec.route("/delitos_secretariado/<int:id_delito>", methods=["PUT", "DELETE"])
def cat_delitos_sec_id(id_delito):
    if request.method == 'PUT':
        data = request.get_json()
        response, status_code = Cat_modalidad_service().update(id_delito, data)
        return response, status_code

    elif request.method == 'DELETE':
        response, status_code = Cat_modalidad_service().delete(id_delito)
        return response, status_code 

@cat_delitos_sec.route("/delitos_secretariado", methods=["GET"])
def cat_delitos_sec_get():
    if request.method == 'GET':
        response, status_code = Cat_modalidad_service().select_all()
        return response, status_code

@cat_delitos_sec.route("/delitos_secretariado/<int:id_subtipo_de_delito>", methods=["GET"])
def cat_delitos_sec_id_subtipo_get(id_subtipo_de_delito):
    if request.method == 'GET':
        response, status_code = Cat_modalidad_service().select_por_id_subtipo(id_subtipo_de_delito)
        return response, status_code