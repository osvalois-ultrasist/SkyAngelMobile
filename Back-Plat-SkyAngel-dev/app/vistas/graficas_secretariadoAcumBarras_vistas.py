import json
from app.controladores.graficas_secretariadoAcumBarras_controladores import secretariadoBarrasAcumService
from flask import Blueprint, request, jsonify

graficasSecBarrasAcum_bp = Blueprint('secretariado/graficas/acumulado-mensual-barras', __name__)

@graficasSecBarrasAcum_bp.route("/secretariado/graficas/acumulado-mensual-barras", methods=["POST"])
def secBarrasAcum():
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response = secretariadoBarrasAcumService().obtenerDatos(parametros)
        return response

