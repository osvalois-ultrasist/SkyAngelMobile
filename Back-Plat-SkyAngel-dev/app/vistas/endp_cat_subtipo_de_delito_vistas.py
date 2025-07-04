'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_cat_subtipo_de_delito import Cat_subtipo_de_delito_service                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
cat_subtipo = Blueprint('cat_subtipo', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@cat_subtipo.route("/subtipo_de_delito",methods=["POST"])
def cat_subtipo_post():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = Cat_subtipo_de_delito_service().insert(data)
        return response, status_code

@cat_subtipo.route("/subtipo_de_delito/id_tipo_de_delito",methods=["POST"])
def cat_subtipo_idTipoDeDelito_post():
    if request.method == 'POST':
        data = request.get_json()
        id_tipo_de_delito = data.get('id_tipo_de_delito', [])
        response = Cat_subtipo_de_delito_service().select_subtipoDeDelito_por_idTipoDeDelito(id_tipo_de_delito)
        return response

@cat_subtipo.route("/subtipo_de_delito/<int:id_subtipo_de_delito>", methods=["PUT", "DELETE"])
def cat_subtipo_id(id_subtipo_de_delito):
    if request.method == 'PUT':
        data = request.get_json()
        response, status_code = Cat_subtipo_de_delito_service().update(id_subtipo_de_delito, data)
        return response, status_code

    elif request.method == 'DELETE':
        response, status_code = Cat_subtipo_de_delito_service().delete(id_subtipo_de_delito)
        return response, status_code 

@cat_subtipo.route("/subtipo_de_delito", methods=["GET"])
def cat_subtipo_get():
    if request.method == 'GET':
        response, status_code = Cat_subtipo_de_delito_service().select_all()
        return response, status_code

@cat_subtipo.route("/subtipo_de_delito/<int:id_tipo_de_delito>", methods=["GET"])
def cat_subtipo_id_tipo_get(id_tipo_de_delito):
    if request.method == 'GET':
        response, status_code = Cat_subtipo_de_delito_service().select_por_id_tipo(id_tipo_de_delito)
        return response, status_code

