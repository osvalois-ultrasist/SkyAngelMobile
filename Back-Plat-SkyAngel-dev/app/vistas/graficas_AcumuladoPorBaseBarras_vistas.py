import json
from flask import Blueprint, request, jsonify
from app.controladores.graficas_AcumuladoPorBaseBarras_controladores import AcumuladoBarrasPorBaseService

graficasAcumuladoBarrasPorBase_bp = Blueprint('/Acumulado/graficas/porBase-barras', __name__)

@graficasAcumuladoBarrasPorBase_bp.route("/Acumulado/graficas/porBase-barras", methods=["POST"])
def AcumuladoBarrasPorBase():
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response = AcumuladoBarrasPorBaseService().obtenerDatos(parametros)
        return response