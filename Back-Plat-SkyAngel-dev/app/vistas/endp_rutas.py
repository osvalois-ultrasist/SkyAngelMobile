import requests
import json
from flask import Blueprint, request, jsonify
from app.controladores.fun_login import *
from app.configuraciones.config import Config               # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
ruta = Blueprint('ruta', __name__)        


@ruta.route("/route",methods=["GET"])
def get_ruta():
    record = json.loads(request.args.get('json'))
    record['alternates'] = 3
    record['language'] = "es-ES"
    # record['format'] = 'osrm'
    valhalla_host = Config.VALHALLA_HOST
    url = valhalla_host+'/route'   
    r = requests.get(url,json=record)
    return r.json()
