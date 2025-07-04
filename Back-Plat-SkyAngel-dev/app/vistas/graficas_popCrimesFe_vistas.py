import json
from flask import Blueprint, request, jsonify
from app.controladores.graficas_popCrimesFeEst_controladores import barrasAcumServiceEntidadAnerpv
from app.controladores.graficas_popCrimesFeMun_controladores import barrasAcumServiceMunSelAnerpv
from app.controladores.graficas_popCrimesFeFed_controladores import barrasAcumServiceAnerpv
# Crear el Blueprint consolidado
graficasFeConsolidado_bp = Blueprint('popular-crimes-Fe', __name__)

class FeEndpointHandler:
    """Clase para manejar todos los endpoints de Fuente Externa"""
    
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
            data, status_code = service_instance.obtenerDatos(parametros)
            return data, status_code
        except ValueError as e:
            return {"error": f"Valor inválido: {str(e)}"}, 400
        except Exception as e:
            print(f"Error en servicio Fuente Externa: {e}")
            return {"error": "Error del servidor"}, 500
    
    @staticmethod
    def process_request(service_class, required_params):
        """Procesa una petición completa con todas las validaciones"""
        if request.method != 'POST':
            return {"error": "Método no permitido"}, 405
        
        # Validar datos del request
        error_response, status = FeEndpointHandler.validate_request_data(request.data)
        if error_response:
            return jsonify(error_response), status
        
        # Validar formato JSON
        parametros, error_response = FeEndpointHandler.validate_json_format(request.data)
        if error_response:
            return jsonify(error_response[0]), error_response[1]
        
        # Validar parámetros requeridos
        error_response, status = FeEndpointHandler.validate_required_params(parametros, required_params)
        if error_response:
            return jsonify(error_response), status
        
        # Procesar con el servicio
        return FeEndpointHandler.handle_service_call(service_class(), parametros)

# Endpoints Fuente Externa Federal
@graficasFeConsolidado_bp.route("/popular-crimes/graficas/totales-federal-Fe", methods=["POST"])
def Fe_federal():
    """Endpoint para gráficas federales de Fuente Externa"""
    return FeEndpointHandler.process_request(
        service_class= barrasAcumServiceAnerpv,
        required_params=["anio", "id_entidad"]
    )

# Endpoints Fuente Externa Estatal
@graficasFeConsolidado_bp.route("/popular-crimes/graficas/totales-estatal-Fe", methods=["POST"])
def Fe_estatal():
    """Endpoint para gráficas estatales de Fuente Externa"""
    return FeEndpointHandler.process_request(
        service_class= barrasAcumServiceEntidadAnerpv,
        required_params=["anio", "id_entidad"]
    )

# Endpoints Fuente Externa Municipal
@graficasFeConsolidado_bp.route("/popular-crimes/graficas/totales-municipal-Fe", methods=["POST"])
def Fe_municipal():
    """Endpoint para gráficas municipales de Fuente Externa"""
    return FeEndpointHandler.process_request(
        service_class=barrasAcumServiceMunSelAnerpv,
        required_params=["anio", "cve_municipio"]
    )

