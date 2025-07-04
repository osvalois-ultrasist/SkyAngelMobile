from flask import Blueprint, request, jsonify, Response
import json
from app.controladores.fun_conteo_reacciones import ConteoReacciones_service

# Se crea la colección de endpoints
sumreacciones = Blueprint('sumreacciones', __name__)

@sumreacciones.route("/reacciones/municipios/delitos", methods=["POST"])
def puntos_interes_filtros():
    if request.method == 'POST':
        data = request.get_json()
        tipoReaccion = data.get('tipoReaccion', [])
        entidad = data.get('entidades',[])
        anio = data.get('anios', [])
        mes = data.get('meses', [])
        municipio = data.get('municipios', [])

        # Decidir qué tipo de datos obtener dependiendo de tipoReaccion
        if tipoReaccion == 1:  # Robos
            puntos_interes_service = ConteoReacciones_service()
            geojson_data = puntos_interes_service.select_incidencias(anio, mes, municipio, entidad)
        elif tipoReaccion == 2:  # Otras incidencias
            puntos_interes_service = ConteoReacciones_service()
            geojson_data = puntos_interes_service.select_otras_incidencias(anio, mes, municipio, entidad)
        elif tipoReaccion == 3:  # Accidentes
            puntos_interes_service = ConteoReacciones_service()
            geojson_data = puntos_interes_service.select_accidentes(anio, mes, municipio, entidad)
        elif tipoReaccion == 4:  # Recuperaciones
            puntos_interes_service = ConteoReacciones_service()
            geojson_data = puntos_interes_service.select_recuperaciones(anio, mes, municipio, entidad)
        else:
            return jsonify({"error": "Tipo de reacción no válido"}), 400

        # Asegurar que la respuesta es JSON válido
        return jsonify(geojson_data)

# Endpoint para obtener el catálogo de reacciones
@sumreacciones.route("/reacciones/catalogo-reacciones", methods=["GET"])
def cat_reacciones():   
    if request.method == 'GET': 
        # Datos del catálogo de reacciones
        data = [{"value": 1, "label": "Robos"},
                {"value": 2, "label": "Otros"},
                {"value": 3, "label": "Accidentes"},
                {"value": 4, "label": "Recuperaciones"}]
        
        # Retornar el catálogo como respuesta en formato JSON
        return jsonify(data), 200