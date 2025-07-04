from flask import Blueprint, request, jsonify
from app.controladores.fun_sum_delitos_entidad_mes_anerpv import DelitosEntidadAnerpv_service

# Se crea la coleccion de endpoints                           
delEntMes = Blueprint('delEntMes', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@delEntMes.route("/anerpv/delitos/entidades",methods=["POST","GET","DELETE"])
def entDel_post_or_get():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = DelitosEntidadAnerpv_service().insert(data)
        return response, status_code

    elif request.method == 'GET':
        response, status_code  = DelitosEntidadAnerpv_service().select_all()
        return response, status_code
    
    elif request.method == 'DELETE':
        data = request.get_json()
        response, status_code = DelitosEntidadAnerpv_service().delete(data)
        return response, status_code 

@delEntMes.route("/anerpv/delitos/entidades/catalogo",methods=["GET"])
def entDel_entidades_get():
    if request.method == 'GET':
        response, status_code  = DelitosEntidadAnerpv_service().select_distinct_entidades()
        return response, status_code

@delEntMes.route("/anerpv/delitos/entidades/filtros",methods=["POST"])
def entDel_filtros_post():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = DelitosEntidadAnerpv_service().select_vista(data)
        return response, status_code