'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_cat_modalidad_anerpv import CatModalidadAnerpv_service

# Se crea la coleccion de endpoints                           
catModAn = Blueprint('catModAn', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@catModAn.route("/anerpv/modalidades",methods=["POST","GET"])
def catModAn_post_or_get():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = CatModalidadAnerpv_service().insert(data)
        return response, status_code

    elif request.method == 'GET':
        response, status_code = CatModalidadAnerpv_service().select_all()
        return response, status_code
    

@catModAn.route("/anerpv/modalidades/<int:id_modalidad_anerpv>", methods=["PUT", "DELETE"])
def catModAn_put_or_delete(id_modalidad_anerpv):
    if request.method == 'PUT':
        data = request.get_json()
        response, status_code = CatModalidadAnerpv_service().update(id_modalidad_anerpv, data)
        return response, status_code

    elif request.method == 'DELETE':
        response, status_code = CatModalidadAnerpv_service().delete(id_modalidad_anerpv)
        return response, status_code 