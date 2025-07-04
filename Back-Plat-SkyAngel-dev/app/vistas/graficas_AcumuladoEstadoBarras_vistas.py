import json
from flask import Blueprint, request, jsonify
from app.controladores.graficas_AcumuladoEstadoBarras_controladores import AcumuladoBarrasEstadoService

graficasAcumuladoBarrasEstado_bp = Blueprint('Acumulado/graficas/estado-barras', __name__)

@graficasAcumuladoBarrasEstado_bp.route("/Acumulado/graficas/estado-barras", methods=["POST"])
def AcumuladoBarrasEstado():
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response = AcumuladoBarrasEstadoService().obtenerDatos(parametros)
        return response
