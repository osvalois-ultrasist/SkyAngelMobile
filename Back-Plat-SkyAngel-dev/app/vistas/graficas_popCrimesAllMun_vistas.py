import json
from app.controladores.graficas_allFuentes_Mun_controladores import barrasAcumServiceAllFuentesMun
from flask import Blueprint, request, jsonify

graficasAllFuentes_bp = Blueprint('/popular-crimes/graficas/totales-mun-all', __name__)

@graficasAllFuentes_bp.route("/popular-crimes/graficas/totales-mun-all", methods=["POST"])
def secBarrasAcum():
    if request.method == 'POST':
        try:
            if not request.data:
                 return jsonify({"error": "No se proporcionarion datos"}), 400
            
            parametros = json.loads(request.data)

            required_params = ["anio", "id_municipio"]
            
            for param in required_params:
                if param not in parametros or not parametros[param]:
                    return jsonify({"error": f"Falta el parametro: {param}"}), 400

            data,status_code = barrasAcumServiceAllFuentesMun().obtenerDatos(parametros)    
            
            return data, status_code
        
        except json.JSONDecodeError:
            return jsonify({"error": "Formato JSON inválido"}), 400
        except ValueError as e:
            return jsonify({"error": f"Valor inválido"}), 400
        except Exception as e:
            return jsonify({"error": f"Error del servidor!!"}), 500