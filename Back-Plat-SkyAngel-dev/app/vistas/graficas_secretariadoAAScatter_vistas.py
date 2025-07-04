import json
from app.controladores.graficas_secretariadoAAScatter_controladores import secretariadoScatterAnioAnteriorService
from flask import Blueprint, request, jsonify

graficasSecScatterAnioAnterior_bp = Blueprint('secretariado/graficas/anio-anterior-scatter', __name__)

@graficasSecScatterAnioAnterior_bp.route("/secretariado/graficas/anio-anterior-scatter", methods=["POST"])
def secScatterAnioAnterior():
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response = secretariadoScatterAnioAnteriorService().obtenerDatos(parametros)
        return response
