'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_sum_delitos_municipio_mes import Sum_delitos_municipio_mes_service
from app.controladores.fun_sum_delitos_municipio_mes_anerpv import DelitosMunicipiosAnerpv_service

# Se crea la coleccion de endpoints                           
delMunMes = Blueprint('delMunMes', __name__)        

@delMunMes.route("/anerpv/municipios/delitos",methods=["POST"])
def sum_delitos_anerpv():
    if request.method == 'POST':
        data = request.get_json()
        anios = data.get('anios', [])
        meses = data.get('meses', [])
        municipios = data.get('municipios', [])
        if municipios == [0]:
            municipios = [i+1 for i in range(32057)]
        modalidades = [10,53] 
        subtiposDelitos = [41]
        response = Sum_delitos_municipio_mes_service().select_vista(modalidades, subtiposDelitos, anios, meses, municipios)
        return response

@delMunMes.route("/anerpv/delitos/municipios",methods=["POST","DELETE"])
def delitos_mun():
    if request.method == 'POST':
        data = request.get_json()
        response = DelitosMunicipiosAnerpv_service().insert(data)
        return response

    if request.method == 'DELETE':
        data = request.get_json()
        response = DelitosMunicipiosAnerpv_service().delete(data)
        return response

@delMunMes.route("/anerpv/delitos/municipios",methods=["GET"])
def delitos_mun_get():
    if request.method == 'GET':
        response = DelitosMunicipiosAnerpv_service().select_all()
        return response

@delMunMes.route("/anerpv/delitos/municipios/entidad",methods=["POST","GET"])
def delitos_mun_ent_post():
    if request.method == 'POST':
        data = request.get_json()
        id_entidad = data.get('idEntidad', [])
        response = DelitosMunicipiosAnerpv_service().select_municipios_por_id_entidad(id_entidad)
        return response
    
    elif request.method == 'GET':
        response = DelitosMunicipiosAnerpv_service().select_municipios_entidad()
        return response

@delMunMes.route("/anerpv/delitos/municipios/filtros",methods=["POST"])
def delitos_mun_filtros_post():
    if request.method == 'POST':
        data = request.get_json()
        response = DelitosMunicipiosAnerpv_service().select_vista(data)
        return response

@delMunMes.route("/anerpv/delitos/municipios/catalogo",methods=["GET"])
def delitos_mun_distinct_get():
    if request.method == 'GET':
        response = DelitosMunicipiosAnerpv_service().select_distinct_municipios()
        return response