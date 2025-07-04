import json
from app.controladores.graficas_fuenteExternaBarrasVehiculo_controladores import funFuenteExternaBarrasVehiculoService
from flask import Blueprint, request, jsonify

fuenteExternaBarrasVehiculo_bp = Blueprint('fuente-externa/graficas/vehiculos-barras', __name__)
@fuenteExternaBarrasVehiculo_bp.route("/fuente-externa/graficas/vehiculos-barras",methods=["POST"])
def fuenteExternaBarrasVehiculo():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            data, code = funFuenteExternaBarrasVehiculoService().obtenerDatos(parametros)
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


