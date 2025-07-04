import json
from app.controladores.graficas_fuenteExternaVelas_controladores import funFuenteExternaVelasService
from flask import Blueprint, request, jsonify

fuenteExternaVelas_bp = Blueprint('fuente-externa/graficas/cierre-apertura-max-min-velas', __name__)

@fuenteExternaVelas_bp.route("/fuente-externa/graficas/cierre-apertura-max-min-velas", methods=["POST"])
def fuenteExternaVelas():
    
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            data, code = funFuenteExternaVelasService().obtenerDatos(parametros)
            
            # Si la respuesta es una cadena JSON, conviértela en un diccionario
            if isinstance(data, str):
                data = json.loads(data)

            # Usamos jsonify para asegurar una correcta respuesta JSON
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
