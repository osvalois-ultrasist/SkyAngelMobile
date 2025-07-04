'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_cat_bien_juridico_afectado import Cat_bien_juridico_service                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
cat_bien = Blueprint('cat_bien', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@cat_bien.route("/bien_juridico",methods=["POST","GET"])
def cat_bien_post_get():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = Cat_bien_juridico_service().insert(data)
        return response, status_code
    
    elif request.method == 'GET':
        response, status_code = Cat_bien_juridico_service().select_all()
        return response, status_code

@cat_bien.route("/bien_juridico/<int:id_bien_juridico_afectado>", methods=["PUT", "DELETE"])
def cat_bien_id(id_bien_juridico_afectado):
    if request.method == 'PUT':
        data = request.get_json()
        response, status_code = Cat_bien_juridico_service().update(id_bien_juridico_afectado, data)
        return response, status_code

    elif request.method == 'DELETE':
        response, status_code = Cat_bien_juridico_service().delete(id_bien_juridico_afectado)
        return response, status_code 