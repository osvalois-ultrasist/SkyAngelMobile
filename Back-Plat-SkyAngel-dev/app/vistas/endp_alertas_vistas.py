from flask import Blueprint, request, jsonify
from app.controladores.fun_alerta import AlertaService
# Se crea la colección de endpoints
alerta_bp = Blueprint("alerta", __name__)

#Función que recibe alerta (POST), la procesa y emite por Websocket
@alerta_bp.route("/alerta", methods=["POST"])
def recibir_alerta():
    try:
        # Verificamos que el contenido sea JSON
        if not request.is_json:
            return jsonify({"error": "El cuerpo de la solicitud debe ser JSON"}), 400
        # Extraer la alerta del cuerpo de la solicitud
        data = request.get_json()
        # Verificar que los campos requeridos esten presentes
        required_params = ["tipo", "incidencia", "coordenadas", "comentario"]
        for param in required_params:
            if param not in data:
                return jsonify({"error": f"Falta el parametro: {param}"}), 400
        # Verificar que los campos requeridos tengan contenido
        for param in required_params:
            if not data[param]:
                return jsonify({"error": f"El parametro {param} esta vacío"}), 400
        # Procesar la alerta con nuevos datos
        data_actualizada = AlertaService().alerta_completa(data)
        # Emitir alerta a todos los clientes conectados
        AlertaService().emitir_alerta(data_actualizada)
        # Guardar la alerta en la base de datos
        response= AlertaService().insert(data_actualizada)
        if not response:
            return jsonify({"error":"No se encontraron datos"}), 404
        return response, 200
    except ValueError as ve:
        return jsonify({"error":str(ve)}), 400
    except Exception:
        return jsonify({"error":"Error de servidor"}), 500

# Funcion que devuelve todas las alertas activas en formato GeoJSON
@alerta_bp.route("/alertas_activas", methods=["GET"])
def alertas_activas():
        try:
            # Llamar al servicio para obtener las alertas activas
            response = AlertaService().get_alertas_activas()
            if not response:
                return jsonify({"error": "No se encontraron datos"}), 400
            
            return response, 200
        except Exception:
            return jsonify({"error": "Error de servidor"}), 500
      
@alerta_bp.route("/categorias", methods=["GET"])
def obtener_categorias():
    try:
        # Llamar al servicio para obtener las categorias
        data = AlertaService().obtener_categorias()
        if not data:
            return jsonify({"error": "No se encontraron categorias"}), 400
        return jsonify(data), 200
    except Exception:
        return jsonify({"error": "Error al obtener las categorias"}), 500
    
@alerta_bp.route("/subcategorias", methods=["GET"])
def obtener_subcategorias():
    try:
        # Llamar al servicio para obtener las subcategorias
        data = AlertaService().obtener_subcategorias()
        if not data:
            return jsonify({"error": "No se encontraron subcategorias"}), 400
        return jsonify(data), 200
    except Exception:
        return jsonify({"error": "Error al obtener las subcategorias"}), 500