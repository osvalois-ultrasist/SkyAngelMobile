import json
from flask import Blueprint, request, jsonify
from app.controladores.funSecretariadoBarras import funSecretariadoBarrasService

secBarras_bp = Blueprint('secBarras', __name__)

@secBarras_bp.route("/secBarras",methods=["POST"])
def secBarras():
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response, code = funSecretariadoBarrasService().obtenerDatos(parametros)
    return response, code
