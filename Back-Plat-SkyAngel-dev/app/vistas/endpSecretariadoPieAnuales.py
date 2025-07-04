import json
from app.controladores.funSecretariadoPieAnuales import secretariadoPieAnualesService
from app.controladores.funSecretariadoPieTipoDeDelito import secretariadoPieTipoDeDelitoService
from app.controladores.funSecretariadoPieSubtipoDeDelito import secretariadoPieSubtipoDeDelitoService
from app.controladores.funSecretariadoPieModalidad import secretariadoPieModalidadService
from flask import Blueprint, request

secPieAnuales_bp = Blueprint('secPieAnuales', __name__)
@secPieAnuales_bp.route("/secPieAnuales",methods=["POST"])
def secPieAnuales():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            response, code = secretariadoPieAnualesService().obtenerDatos(parametros)
            return response, code
    except Exception as e:
        return ({"error": str(e)}), 500



secPieTipoDeDelito_bp = Blueprint('secPieTipoDeDelito', __name__)
@secPieTipoDeDelito_bp.route("/secPieTipoDeDelito",methods=["POST"])
def secPieTipoDelito():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            response, code = secretariadoPieTipoDeDelitoService().obtenerDatos(parametros)
            return response, code
    except Exception as e:
        return ({"error": str(e)}), 500



secPieSubtipoDeDelito_bp = Blueprint('secPieSubtipoDeDelito', __name__)
@secPieSubtipoDeDelito_bp.route("/secPieSubtipoDeDelito",methods=["POST"])
def secPieSubtipoDelito():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            response, code = secretariadoPieSubtipoDeDelitoService().obtenerDatos(parametros)
            return response, code
    except Exception as e:
        return ({"error": str(e)}), 500



secPieModalidad_bp = Blueprint('secPieModalidad', __name__)
@secPieModalidad_bp.route("/secPieModalidad",methods=["POST"])
def secPieModalidadDelito():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            response, code = secretariadoPieModalidadService().obtenerDatos(parametros)
            return response, code
    except Exception as e:
        return ({"error": str(e)}), 500
