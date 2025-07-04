import json
from flask import Blueprint, request, jsonify
from app.controladores.graficas_popCrimesAllEst_controladores import barrasServiceAllFuentesEntidad
from app.controladores.graficas_popCrimesAllFed_controladores import barrasAcumServiceAnerpvSecretariado
from app.controladores.graficas_allFuentes_Mun_controladores import barrasAcumServiceAllFuentesMun

# Crear el Blueprint consolidado
graficasAllConsolidado_bp = Blueprint('popular-crimes-All', __name__)

class AllEndpointHandler:
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
            data, status_code = service_instance.obtenerDatos(parametros)
            return data, status_code
        except ValueError as e:
            return {"error": f"Valor inválido: {str(e)}"}, 400
        except Exception as e:
            print(f"Error en servicio Todas las fuentes: {e}")
            return {"error": "Error del servidor"}, 500
    
    @staticmethod
    def process_request(service_class, required_params):
        """Procesa una petición completa con todas las validaciones"""
        if request.method != 'POST':
            return {"error": "Método no permitido"}, 405
        
        # Validar datos del request
        error_response, status = AllEndpointHandler.validate_request_data(request.data)
        if error_response:
            return jsonify(error_response), status
        
        # Validar formato JSON
        parametros, error_response = AllEndpointHandler.validate_json_format(request.data)
        if error_response:
            return jsonify(error_response[0]), error_response[1]
        
        # Validar parámetros requeridos
        error_response, status = AllEndpointHandler.validate_required_params(parametros, required_params)
        if error_response:
            return jsonify(error_response), status
        
        # Procesar con el servicio
        return AllEndpointHandler.handle_service_call(service_class(), parametros)

# Endpoints Todas las fuentes Allderal
@graficasAllConsolidado_bp.route("/popular-crimes/graficas/totales-federal-all", methods=["POST"])
def All_federal():
    """Endpoint para gráficas federales de Todas las fuentes"""
    return AllEndpointHandler.process_request(
        service_class= barrasServiceAllFuentesEntidad,
        required_params=["anio", "id_entidad"]
    )

# Endpoints Todas las fuentes Estatal
@graficasAllConsolidado_bp.route("/popular-crimes/graficas/totales-estatal-all", methods=["POST"])
def All_estatal():
    """Endpoint para gráficas estatales de Todas las fuentes"""
    return AllEndpointHandler.process_request(
        service_class= barrasServiceAllFuentesEntidad,
        required_params=["anio", "id_entidad"]
    )

# Endpoints Todas las fuentes Municipal
@graficasAllConsolidado_bp.route("/popular-crimes/graficas/totales-municipal-all", methods=["POST"])
def All_municipal():
    """Endpoint para gráficas municipales de Todas las fuentes"""
    return AllEndpointHandler.process_request(
        service_class=barrasAcumServiceAllFuentesMun,
        required_params=["anio", "id_municipio"]
    )

