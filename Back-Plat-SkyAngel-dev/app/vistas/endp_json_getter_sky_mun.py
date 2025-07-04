import json
from flask import Blueprint, request, jsonify
from app.controladores.funGetter_json_controlador_sky_mun import GetJsonMunicipioServiceSky
getterJsonSkyMun_bp = Blueprint('/popular-crimes/get-json-sky-mun', __name__)

@getterJsonSkyMun_bp.route("/popular-crimes/get-json-sky-mun", methods=["POST"])
def secBarrasMunicipio():
    if request.method == 'POST':
        try:
            if not request.data:
                 return jsonify({"error": "No se proporcionarion datos"}), 400
            
            parametros = json.loads(request.data)

            required_params = ["anio", "id_municipio"]
            
            for param in required_params:
                if param not in parametros or not parametros[param]:
                    return jsonify({"error": f"Falta el parametro: {param}"}), 400

            data = GetJsonMunicipioServiceSky().obtenerDatos(parametros)    
            
            
            return jsonify(data), 200
        
        except json.JSONDecodeError:
            return jsonify({"error": "Formato JSON inválido"}), 400
        except ValueError as e:
            return jsonify({"error": f"Valor inválido"}), 400
        except Exception as e:
            return jsonify({"error": f"Error del servidor!!"}), 500