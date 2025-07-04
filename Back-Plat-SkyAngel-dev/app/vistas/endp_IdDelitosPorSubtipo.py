import json
import os
from flask import Blueprint, request, jsonify
from app.controladores.fun_idDelitosPorSubtipo import IdDelitosPorSubtipo_service

# Se crea la coleccion de endpoints                           
idDelitosPorSubtipo = Blueprint('idDelitosPorSubtipo', __name__)
      
@idDelitosPorSubtipo.route("/iddelitosporsubtipo", methods=["POST"])
def idDelitosPorSubtipo_post():
    if request.method == 'POST':
        data = request.get_json()
        # Extraer la lista de subtipos desde la clave 'delitos'
        subTipos = data.get('subtipos', [])
        # Llamar al servicio con los subTipos obtenidos
        response, status_code = IdDelitosPorSubtipo_service().selectDelitoPorSubtipoMapper(subTipos)
        return response, status_code