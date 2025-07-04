import json
from flask import Blueprint, request, jsonify
from app.controladores.graficas_reaccionesDelitoBarras_controladores import reaccionesBarrasDelitoService

reaccionesBarrasDelito_bp = Blueprint('/reacciones/graficas/delito-barras', __name__)

@reaccionesBarrasDelito_bp.route("/reacciones/graficas/delito-barras", methods=["POST"])
def reaccionesBarrasDelito():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            data = reaccionesBarrasDelitoService().obtenerDatos(parametros)
            response = jsonify(data)
            response.status_code = 200
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