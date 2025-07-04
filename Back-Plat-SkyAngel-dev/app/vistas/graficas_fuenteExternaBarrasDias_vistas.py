import json
from app.controladores.graficas_fuenteExternaBarrasDias_controladores import funFuenteExternaBarrasDiasService
from flask import Blueprint, request, jsonify

fuenteExternaBarrasDias_bp = Blueprint('fuente-externa/graficas/anio-meses-dias-barras', __name__)

@fuenteExternaBarrasDias_bp.route("/fuente-externa/graficas/anio-meses-dias-barras", methods=["POST"])
def fuenteExternaBarrasDias():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            data, code = funFuenteExternaBarrasDiasService().obtenerDatos(parametros)
            response = jsonify(data)
            response.status_code = code
            return response

    except KeyError as e:
        response = jsonify({"error": f"Parámetro faltante: {str(e)}"})
        response.status_code = 400
        return response

    except ValueError as e:
        response = jsonify({"error": f"Valor inválido: {str(e)}"})
        response.status_code = 400
        return response

    except Exception as e:
        response = jsonify({"error": f"Error del servidor: {str(e)}"})
        response.status_code = 500
        return response
