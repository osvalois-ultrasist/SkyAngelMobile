'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_cat_modalidad import Cat_modalidad_service                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
cat_mod = Blueprint('cat_mod', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@cat_mod.route("/modalidad",methods=["POST"])
def cat_mod_post():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = Cat_modalidad_service().insert(data)
        return response, status_code

# Queda como respaldo
@cat_mod.route("/modalidad/id_subtipo_de_delito2",methods=["POST"])
def cat_mod_idSubtipoDeDelito_post():
    if request.method == 'POST':
        data = request.get_json()
        # Extraer la lista de tipo de delitos desde la clave 'id_bien_juridico_afectado'
        id_subtipo_de_delito = data.get('id_subtipo_de_delito', [])
        # Llamar al servicio con los subTipos obtenidos
        response, status_code = Cat_modalidad_service().select_modalidad_por_idSubtipoDeDelito(id_subtipo_de_delito)
        return response, status_code

@cat_mod.route("/modalidad/id_subtipo_de_delito",methods=["POST"])
def cat_mod_delitos_vista():
    if request.method == 'POST':
        data = request.get_json()
        # Extraer la lista de tipo de delitos desde la clave 'id_bien_juridico_afectado'
        subtipoDeDelito = data.get('id_subtipo_de_delito', [])
        # Llamar al servicio con los subTipos obtenidos
        response, status_code = Cat_modalidad_service().select_modalidad_delitos_vista(subtipoDeDelito)
        return response, status_code

@cat_mod.route("/modalidad/<int:id_modalidad>", methods=["PUT", "DELETE"])
def cat_mod_id(id_modalidad):
    if request.method == 'PUT':
        data = request.get_json()
        response, status_code = Cat_modalidad_service().update(id_modalidad, data)
        return response, status_code

    elif request.method == 'DELETE':
        response, status_code = Cat_modalidad_service().delete(id_modalidad)
        return response, status_code 

@cat_mod.route("/modalidad", methods=["GET"])
def cat_mod_get():
    if request.method == 'GET':
        response, status_code = Cat_modalidad_service().select_all()
        return response, status_code