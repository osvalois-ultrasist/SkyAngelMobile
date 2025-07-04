import json
from flask import Blueprint, request, jsonify
from app.controladores.graficas_secretariadoMunicipioBarras_controladores import secretariadoBarrasMunicipioService

graficasSecBarrasMunicipio_bp = Blueprint('secretariado/graficas/municipio-barras', __name__)

@graficasSecBarrasMunicipio_bp.route("/secretariado/graficas/municipio-barras", methods=["POST"])
def secBarrasMunicipio():
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response = secretariadoBarrasMunicipioService().obtenerDatos(parametros)
        
        return response