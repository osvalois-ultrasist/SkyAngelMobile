import json
from app.controladores.graficas_fuenteExternaScatterAA_controladores import funFuenteExternaScatterService
from flask import Blueprint, request, jsonify

fuenteExternaScatter_bp = Blueprint('fuente-externa/graficas/anio-anterior-scatter', __name__)

@fuenteExternaScatter_bp.route("/fuente-externa/graficas/anio-anterior-scatter", methods=["POST"])
def fuenteExternaScatter():
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response = funFuenteExternaScatterService().obtenerDatos(parametros)
        return response