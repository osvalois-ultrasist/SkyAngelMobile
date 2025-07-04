from flask import Blueprint, request, jsonify
from app.controladores.fun_sum_delitos_nacional_mes_anerpv import DelitosNacionalAnerpv_service

# Se crea la coleccion de endpoints                           
delNacMes = Blueprint('delNacMes', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@delNacMes.route("/anerpv/delitos/nacional",methods=["POST","GET","DELETE"])
def delnacmes_post_or_get():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = DelitosNacionalAnerpv_service().insert(data)
        return response, status_code

    elif request.method == 'GET':
        response, status_code  = DelitosNacionalAnerpv_service().select_all()
        return response, status_code
    
    elif request.method == 'DELETE':
        data = request.get_json()
        response, status_code = DelitosNacionalAnerpv_service().delete(data)
        return response, status_code 

@delNacMes.route("/anerpv/delitos/nacional/filtros",methods=["POST"])
def delnacmes_get():
    if request.method == 'POST':
        data = request.get_json()
        anio = data.get('anios', [])
        id_mes = data.get('meses', [])
        response, status_code = DelitosNacionalAnerpv_service().select_anio(anio, id_mes)
        return response, status_code