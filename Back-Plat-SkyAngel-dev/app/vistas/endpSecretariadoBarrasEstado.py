import json
from app.controladores.funSecretariadoBarrasEstado import secretariadoBarrasEstadoService
from app.controladores.funSecretariadoBarrasMunicipio import secretariadoBarrasMunicipioService
from app.controladores.funSecretariadoBarrasAcum import secretariadoBarrasAcumService
from flask import Blueprint, request

secBarrasEstado_bp = Blueprint('secBarrasEstado', __name__)
@secBarrasEstado_bp.route("/secBarrasEstado",methods=["POST"])
def secBarrasEstado():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            response, code = secretariadoBarrasEstadoService().obtenerDatos(parametros)
            return response, code
    except Exception as e:
        return ({"error": str(e)}), 500



secBarrasMunicipio_bp = Blueprint('secBarrasMunicipio', __name__)
@secBarrasMunicipio_bp.route("/secBarrasMunicipio",methods=["POST"])
def secBarrasMunicipio():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            response, code = secretariadoBarrasMunicipioService().obtenerDatos(parametros)
            return response, code
    except Exception as e:
        return ({"error": str(e)}), 500


secBarrasAcum_bp = Blueprint('secBarrasAcum', __name__)
@secBarrasAcum_bp.route("/secBarrasAcum",methods=["POST"])
def secBarrasAcum():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            response, code = secretariadoBarrasAcumService().obtenerDatos(parametros)
            return response, code
    except Exception as e:
        return ({"error": str(e)}), 500
