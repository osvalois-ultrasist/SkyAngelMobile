import json
from app.controladores.graficas_reaccionesCachimbasBarras_controladores import funreaccionesCachimbasBarrasService
from flask import Blueprint, request, jsonify

reaccionesCachimbasBarras_bp = Blueprint('/reacciones/graficas/cachimbas-barras', __name__)

@reaccionesCachimbasBarras_bp.route("/reacciones/graficas/cachimbas-barras", methods=["POST"])
def reaccionesCachimbasBarras():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            
            data, code = funreaccionesCachimbasBarrasService().obtenerDatos(parametros)
            
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