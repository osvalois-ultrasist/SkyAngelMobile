import json
from flask import Blueprint, request, jsonify
from app.controladores.graficas_fuenteExternaPie_controladores import funFuenteExternaPieService

fuenteExternaPie_bp = Blueprint('fuente-externa/graficas/fuente-externa/graficas/anio-meses-dias-pie', __name__)

@fuenteExternaPie_bp.route("/fuente-externa/graficas/anio-meses-dias-pie", methods=["POST"])
def fuenteExternaPie():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            
            # Validación de parámetros esenciales
            for key in ["anio", "mes", "entidad"]:
                if key not in parametros:
                    raise KeyError(f"{key}")

            data, code = funFuenteExternaPieService().obtenerDatos(parametros)
            
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
