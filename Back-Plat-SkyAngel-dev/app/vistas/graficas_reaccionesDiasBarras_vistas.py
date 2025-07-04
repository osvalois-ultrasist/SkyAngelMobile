import json
from app.controladores.graficas_reaccionesDiasBarras_controladores import funreaccionesDiasBarrasService
from flask import Blueprint, request, jsonify

reaccionesDiasBarras_bp = Blueprint('/reacciones/graficas/dias-barras', __name__)

@reaccionesDiasBarras_bp.route("/reacciones/graficas/dias-barras", methods=["POST"])
def reaccionesDiasBarras():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            
            data, code = funreaccionesDiasBarrasService().obtenerDatos(parametros)
            
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

    except json.JSONDecodeError:
        response = jsonify({"error": "El cuerpo de la solicitud debe ser JSON válido"})
        response.status_code = 400
        return response

    except Exception as e:
        response = jsonify({"error": f"Error del servidor: {str(e)}"})
        response.status_code = 500
        return response