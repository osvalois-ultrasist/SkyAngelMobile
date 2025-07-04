import json
from flask import Blueprint, request, jsonify
from app.controladores.funGetter_json_sub_del_controlador_anerpv import GetJsonSubtipoEntidadServiceAnerpv
getterJsonSubDelAnerpv_bp = Blueprint('/popular-crimes/get-json-fed-sec-anerpv', __name__)

@getterJsonSubDelAnerpv_bp.route("/popular-crimes/get-json-fed-sec-anerpv", methods=["POST"])
def secBarrasMunicipio():
    if request.method == 'POST':
        try:
            if not request.data:
                 return jsonify({"error": "No se proporcionarion datos"}), 400
            
            parametros = json.loads(request.data)

            required_params = ["anio", "id_entidad"]
            
            for param in required_params:
                if param not in parametros or not parametros[param]:
                    return jsonify({"error": f"Falta el parametro: {param}"}), 400

            data = GetJsonSubtipoEntidadServiceAnerpv().obtenerDatos(parametros)    
            
            print(data)
            return jsonify(data), 200
        
        except json.JSONDecodeError:
            return jsonify({"error": "Formato JSON inválido"}), 400
        except ValueError as e:
            return jsonify({"error": f"Valor inválido"}), 400
        except Exception as e:
            return jsonify({"error": f"Error del servidor!!"}), 500