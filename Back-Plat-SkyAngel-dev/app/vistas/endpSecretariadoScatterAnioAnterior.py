import json
from app.controladores.funSecretariadoScatterAnioAnterior import secretariadoScatterAnioAnteriorService
from flask import Blueprint, request

secScatterAnioAnterior_bp = Blueprint('secScatterAnioAnterior', __name__)
@secScatterAnioAnterior_bp.route("/secScatterAnioAnterior",methods=["POST"])
def secScatterAnioAnterior():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            response, code = secretariadoScatterAnioAnteriorService().obtenerDatos(parametros)
            return response, code
    except Exception as e:
        return ({"error": str(e)}), 500
