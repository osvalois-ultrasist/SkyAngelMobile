import json
from flask import Blueprint, request, jsonify
from app.controladores.funGetter_json_all_fuentes_controlador_entidad import getterJsonAllEntidad
from app.controladores.funGetter_json_all_fuentes_controlador_municipio import getterJsonAllMunicipio

# Crear el Blueprint consolidado
getterJsonAll_bp = Blueprint('popular-crimes-getter-json-all', __name__)

class GetJsonEndpointHandler:
    """Clase para manejar todos los endpoints de Todas las fuentes"""
    
    @staticmethod
    def validate_request_data(request_data):
        """Valida que los datos del request no estén vacíos"""
        if not request_data:
            return {"error": "No se proporcionaron datos"}, 400
        return None, None
    
    @staticmethod
    def validate_json_format(request_data):
        """Valida que los datos tengan formato JSON válido"""
        try:
            return json.loads(request_data), None
        except json.JSONDecodeError:
            return None, ({"error": "Formato JSON inválido"}, 400)
    
    @staticmethod
    def validate_required_params(parametros, required_params):
        """Valida que estén presentes los parámetros requeridos"""
        for param in required_params:
            if param not in parametros or not parametros[param]:
                return {"error": f"Falta el parámetro: {param}"}, 400
        return None, None
    
    @staticmethod
    def handle_service_call(service_instance, parametros):
        """Maneja la llamada al servicio y retorna la respuesta"""
        try:
            result = service_instance.obtenerDatos(parametros)
            
            # Verificar si el resultado es una tupla (data, status_code) o solo data
            if isinstance(result, tuple) and len(result) == 2:
                data, status_code = result
            else:
                # Si no es una tupla, asumir que es solo data con status 200
                data = result
                status_code = 200
            
            # Si data es una respuesta de Flask (tiene status_code), extraer la data real
            if hasattr(data, 'status_code'):
                status_code = data.status_code
                data = data.get_json() if hasattr(data, 'get_json') else data.data
            
            return data, status_code
            
        except ValueError as e:
            print(f"Error de valor en servicio: {str(e)}")
            return {"error": f"Valor inválido: {str(e)}"}, 400
        except Exception as e:
            print(f"Error en servicio Todas las fuentes: {e}")
            print(f"Tipo de error: {type(e)}")
            return {"error": "Error del servidor"}, 500
    
    @staticmethod
    def process_request(service_class, required_params):
        """Procesa una petición completa con todas las validaciones"""
        try:
            if request.method != 'POST':
                return jsonify({"error": "Método no permitido"}), 405
            
            # Validar datos del request
            error_response, status = GetJsonEndpointHandler.validate_request_data(request.data)
            if error_response:
                return jsonify(error_response), status
            
            # Validar formato JSON
            parametros, error_response = GetJsonEndpointHandler.validate_json_format(request.data)
            if error_response:
                return jsonify(error_response[0]), error_response[1]
            
            # Validar parámetros requeridos
            error_response, status = GetJsonEndpointHandler.validate_required_params(parametros, required_params)
            if error_response:
                return jsonify(error_response), status
            
            # Procesar con el servicio
            data, status_code = GetJsonEndpointHandler.handle_service_call(service_class(), parametros)
            
            # Asegurar que retornamos una respuesta JSON válida
            if isinstance(data, str):
                try:
                    # Si data es un string JSON, parsearlo
                    parsed_data = json.loads(data)
                    return jsonify(parsed_data), status_code
                except json.JSONDecodeError:
                    # Si no es JSON válido, retornar como mensaje
                    return jsonify({"message": data}), status_code
            else:
                return jsonify(data), status_code
                
        except Exception as e:
            print(f"Error en process_request: {e}")
            return jsonify({"error": "Error interno del servidor"}), 500

# Endpoints Todas las fuentes Entidad
@getterJsonAll_bp.route("/popular-crimes/get-json-fed-all", methods=["POST"])
def all_entidad():
    """Endpoint para obtener JSON de todas las fuentes a nivel entidad"""
    return GetJsonEndpointHandler.process_request(
        service_class=getterJsonAllEntidad,
        required_params=["anio", "id_entidad"]
    )

# Endpoints Todas las fuentes Municipal
@getterJsonAll_bp.route("/popular-crimes/get-json-mun-all", methods=["POST"])
def all_municipal():
    """Endpoint para obtener JSON de todas las fuentes a nivel municipal"""
    return GetJsonEndpointHandler.process_request(
        service_class=getterJsonAllMunicipio,
        required_params=["anio", "id_municipio"]
    )


