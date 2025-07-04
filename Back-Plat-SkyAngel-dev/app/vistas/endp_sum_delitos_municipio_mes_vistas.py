'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_sum_delitos_municipio_mes import Sum_delitos_municipio_mes_service

# Se crea la coleccion de endpoints                           
sumdelmun = Blueprint('sumdelmun', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@sumdelmun.route("/sum-delitos-municipios-mes/cargar-csv",methods=["POST"])
def subir_csv():
    if request.method == 'POST':
        if 'file' not in request.files:
            return jsonify({"Error": "No hay archivo"}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({"Error": "No se encuentra el archivo"}), 400
        
        if file and file.filename.endswith('.xlsx'):
            response, status_code = Sum_delitos_municipio_mes_service().procesar_csv(file)
            return response, status_code
        
        return jsonify({"Error": "Formato de archivo no soportado"}), 400

@sumdelmun.route("/municipios/delitos",methods=["POST"])
def sum_delitos_mun_vista_post():
    if request.method == 'POST':
        data = request.get_json()
        modalidades = data.get('modalidades', [])
        subtiposDelitos = data.get('subtiposDelitos', [])
        entidades = data.get('entidades',[])
        anios = data.get('anios', [])
        meses = data.get('meses', [])
        municipios = data.get('municipios', [])
        response = Sum_delitos_municipio_mes_service().select_vista(modalidades, subtiposDelitos, anios, entidades, meses, municipios)
        return response

@sumdelmun.route("/sum-delitos-municipios-mes",methods=["PUT"])
def sum_delitos_mun_mes_put():
    if request.method == 'PUT':
        data = request.get_json()
        response, status_code = Sum_delitos_municipio_mes_service().insert_or_update(data)
        return response, status_code

@sumdelmun.route("/sum-delitos-municipios-mes", methods=["DELETE"])
def sum_delitos_mun_mes_delete():
    if request.method == 'DELETE':
        data = request.get_json()
        response, status_code = Sum_delitos_municipio_mes_service().delete(data)
        return response, status_code

@sumdelmun.route("/sum-delitos-municipios-mes", methods=["GET"])
def sum_delitos_mun_mes_get():
    if request.method == 'GET':
        response, status_code = Sum_delitos_municipio_mes_service().select_all()
        return response, status_code

