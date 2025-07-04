from flask import Blueprint, request, jsonify
from app.controladores.fun_catalogo_municipios import Municipios_service

#Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
municipios = Blueprint('municipios', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@municipios.route("/municipios",methods=["POST"])
def municipios_post():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = Municipios_service().insert(data)
        return response, status_code

@municipios.route("/municipios/<int:cve_municipio>", methods=["PUT", "DELETE"])
def municipios_id(cve_municipio):
    if request.method == 'PUT':
        data = request.get_json()
        response, status_code = Municipios_service().update(cve_municipio, data)
        return response, status_code

    elif request.method == 'DELETE':
        response, status_code = Municipios_service().delete(cve_municipio)
        return response, status_code 

@municipios.route("/municipios", methods=["GET"])
def municipios_get():
    if request.method == 'GET':
        response, status_code = Municipios_service().select_all()
        return response, status_code

@municipios.route("/municipios/<int:id_entidad>", methods=["GET"])
def municipios_id_entidad_get(id_entidad):
    if request.method == 'GET':
        response, status_code = Municipios_service().select_por_id_entidad(id_entidad)
        return response, status_code

@municipios.route("/municipios/id_entidad", methods=["POST"])
def municipios_id_entidad_post():
    if request.method == 'POST':
        data = request.get_json()
        # Extraer la lista de tipo de delitos desde la clave 'id_bien_juridico_afectado'
        id_entidad = data.get('id_entidad', [])
        # Llamar al servicio con los subTipos obtenidos
        response = Municipios_service().select_municipios_por_idEntidad(id_entidad)
        return response