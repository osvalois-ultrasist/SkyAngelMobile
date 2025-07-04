import json
from flask import Blueprint, request, jsonify
from app.controladores.graficas_popCrimesSkyFed_controladores import skyBarrasAcumService
from app.controladores.graficas_popCrimesSkyEst_controladores import skyBarrasMunSelService as skyBarrasEntidadService
from app.controladores.graficas_popCrimesSkyMun_controladores import skyBarrasMunSelService

# Crear el Blueprint consolidado
graficasSkyConsolidado_bp = Blueprint('popular-crimes-sky', __name__)

class SkyEndpointHandler:
    """Clase para manejar todos los endpoints de SkyAngel"""
    
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
            print(f"Error en servicio SkyAngel: {e}")
            return {"error": "Error del servidor"}, 500
    
    @staticmethod
    def process_request(service_class, required_params):
        """Procesa una petición completa con todas las validaciones"""
        if request.method != 'POST':
            return {"error": "Método no permitido"}, 405
        
        # Validar datos del request
        error_response, status = SkyEndpointHandler.validate_request_data(request.data)
        if error_response:
            return jsonify(error_response), status
        
        # Validar formato JSON
        parametros, error_response = SkyEndpointHandler.validate_json_format(request.data)
        if error_response:
            return jsonify(error_response[0]), error_response[1]
        
        # Validar parámetros requeridos
        error_response, status = SkyEndpointHandler.validate_required_params(parametros, required_params)
        if error_response:
            return jsonify(error_response), status
        
        # Procesar con el servicio
        return SkyEndpointHandler.handle_service_call(service_class(), parametros)

# Endpoints SkyAngel Federal
@graficasSkyConsolidado_bp.route("/popular-crimes/graficas/totales-federal-sky", methods=["POST"])
def sky_federal():
    """Endpoint para gráficas federales de SkyAngel"""
    return SkyEndpointHandler.process_request(
        service_class=skyBarrasAcumService,
        required_params=["anio", "id_entidad"]
    )

# Endpoints SkyAngel Estatal
@graficasSkyConsolidado_bp.route("/popular-crimes/graficas/totales-estatal-sky", methods=["POST"])
def sky_estatal():
    """Endpoint para gráficas estatales de SkyAngel"""
    return SkyEndpointHandler.process_request(
        service_class=skyBarrasEntidadService,
        required_params=["anio", "id_entidad"]
    )

# Endpoints SkyAngel Municipal
@graficasSkyConsolidado_bp.route("/popular-crimes/graficas/totales-municipio-sky", methods=["POST"])
def sky_municipal():
    """Endpoint para gráficas municipales de SkyAngel"""
    return SkyEndpointHandler.process_request(
        service_class=skyBarrasMunSelService,
        required_params=["anio", "cve_municipio"]
    )

