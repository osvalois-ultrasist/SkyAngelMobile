import json
from flask import Blueprint, request, jsonify
from app.controladores.graficas_secretariadoEstadoBarras_controladores import secretariadoBarrasEstadoService

graficasSecBarrasEstado_bp = Blueprint('secretariado/graficas/estado-barras', __name__)

@graficasSecBarrasEstado_bp.route("/secretariado/graficas/estado-barras", methods=["POST"])
def secBarrasEstado():
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response = secretariadoBarrasEstadoService().obtenerDatos(parametros)
        return response
