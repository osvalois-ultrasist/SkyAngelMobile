import json
from app.controladores.graficas_fuenteExternaBarras_controladores import funFuenteExternaBarrasService
from flask import Blueprint, request, jsonify

fuenteExternaBarras_bp = Blueprint('fuente-externa/graficas/anio-anterior-barras', __name__)
@fuenteExternaBarras_bp.route("/fuente-externa/graficas/anio-anterior-barras",methods=["POST"])
def fuenteExternaBarras():
    
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            data = funFuenteExternaBarrasService().obtenerDatos(parametros)
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


