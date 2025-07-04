import json
from app.controladores.graficas_secretariadoNivelesPie_controladores import secretariadoPieNivelesService
from flask import Blueprint, request, jsonify

secPieNiveles_bp = Blueprint('secretariado/graficas/bienJuridicoAfectado-tipoDeDelito-subtipoDeDelito-modalidad-pie', __name__)

@secPieNiveles_bp.route("/secretariado/graficas/bienJuridicoAfectado-tipoDeDelito-subtipoDeDelito-modalidad-pie", methods=["POST"])
def secPieNiveles():
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response = secretariadoPieNivelesService().obtenerDatos(parametros)
        return response

