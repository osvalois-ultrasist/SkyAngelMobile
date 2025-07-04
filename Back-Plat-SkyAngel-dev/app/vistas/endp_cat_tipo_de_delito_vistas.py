'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_cat_tipo_de_delito import Cat_tipo_de_delito_service                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
cat_tipo = Blueprint('cat_tipo', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@cat_tipo.route("/tipo_de_delito",methods=["POST","GET"])
def cat_tipo_post():
    if request.method == 'POST':
        data = request.get_json()
        response, status_code = Cat_tipo_de_delito_service().insert(data)
        return response, status_code

    elif request.method == 'GET':
        response, status_code = Cat_tipo_de_delito_service().select_all()
        return response, status_code

@cat_tipo.route("/tipo_de_delito/<int:id_tipo_de_delito>", methods=["PUT", "DELETE"])
def cat_tipo_id(id_tipo_de_delito):
    if request.method == 'PUT':
        data = request.get_json()
        response, status_code = Cat_tipo_de_delito_service().update(id_tipo_de_delito, data)
        return response, status_code

    elif request.method == 'DELETE':
        response, status_code = Cat_tipo_de_delito_service().delete(id_tipo_de_delito)
        return response, status_code 

@cat_tipo.route("/tipo_de_delito/<int:id_bien_juridico_afectado>", methods=["GET"])
def cat_tipo_id_get(id_bien_juridico_afectado):
    if request.method == 'GET':
        response, status_code = Cat_tipo_de_delito_service().select_por_id_bien(id_bien_juridico_afectado)
        return response, status_code

@cat_tipo.route("/tipo_de_delito/id_bien_juridico_afectado", methods=["POST"])
def cat_tipo_id_bien_post():
    if request.method == 'POST':
        data = request.get_json()
        # Extraer la lista de tipo de delitos desde la clave 'id_bien_juridico_afectado'
        id_bien_juridico_afectado = data.get('id_bien_juridico_afectado', [])
        # Llamar al servicio con los subTipos obtenidos
        response = Cat_tipo_de_delito_service().select_tipoDeDelito_por_idBienJuridico(id_bien_juridico_afectado)
        return response