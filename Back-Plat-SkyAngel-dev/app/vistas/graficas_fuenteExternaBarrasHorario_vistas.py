import json
from app.controladores.graficas_fuenteExternaBarrasHorario_controladores import funFuenteExternaBarrasHorarioService
from flask import Blueprint, request, jsonify

fuenteExternaBarrasHorario_bp = Blueprint('fuente-externa/graficas/horario-barras', __name__)

@fuenteExternaBarrasHorario_bp.route("/fuente-externa/graficas/horario-barras", methods=["POST"])
def fuenteExternaBarrasHorario():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            data, code = funFuenteExternaBarrasHorarioService().obtenerDatos(parametros)
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
