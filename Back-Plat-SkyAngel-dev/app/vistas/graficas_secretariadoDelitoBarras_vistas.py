import json
from flask import Blueprint, request, jsonify
from app.controladores.graficas_secretariadoDelitoBarras_controladores import secretariadoBarrasDelitoService

graficasSecBarrasDelito_bp = Blueprint('secretariado/graficas/barras-tipo-delito', __name__)

@graficasSecBarrasDelito_bp.route("/secretariado/graficas/barras-tipo-delito", methods=["POST"])
def secBarrasDelito():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            data = secretariadoBarrasDelitoService().obtenerDatos(parametros)
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