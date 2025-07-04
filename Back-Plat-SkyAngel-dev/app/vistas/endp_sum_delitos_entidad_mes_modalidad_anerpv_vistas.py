from flask import Blueprint, request, jsonify
from app.controladores.fun_sum_delitos_entidad_mes_modalidad_anerpv import DelitosModalidadAnerpv_service

# Se crea la coleccion de endpoints                           
modEntMes = Blueprint('modEntMes', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@modEntMes.route("/anerpv/delitos/entidades/modalidades",methods=["POST","GET","DELETE"])
def modEntMes_post_or_get():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = DelitosModalidadAnerpv_service().insert(data)
        return response, status_code

    elif request.method == 'GET':
        response, status_code  = DelitosModalidadAnerpv_service().select_all()
        return response, status_code
    
    elif request.method == 'DELETE':
        data = request.get_json()
        response, status_code = DelitosModalidadAnerpv_service().delete(data)
        return response, status_code 
