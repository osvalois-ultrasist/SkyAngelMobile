import json
from app.controladores.graficas_reaccionesScatter_controladores import funreaccionesScatterService
from flask import Blueprint, request, jsonify

reaccionesScatter_bp = Blueprint('/reacciones/graficas/scatter', __name__)

@reaccionesScatter_bp.route("/reacciones/graficas/scatter", methods=["POST"])
def skyScatter():
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response = funreaccionesScatterService().obtenerDatos(parametros)
        return response