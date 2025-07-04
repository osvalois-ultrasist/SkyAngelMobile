from flask import Blueprint, request, jsonify
from app.controladores.mapas_controlador import MapasControlador
from app.controladores.fun_sum_delitos_municipio_mes import Sum_delitos_municipio_mes_service

mapas_bp = Blueprint('mapas', __name__)
controlador = MapasControlador()

@mapas_bp.route('/mapas/municipio', methods=['GET'])
def obtener_mapa():
    """
    Endpoint para obtener un archivo GeoJSON según el ID proporcionado.
    """
    # Leer el parámetro de consulta
    id_municipio = request.args.get('idMunicipio')

    # Validar si el parámetro se proporcionó
    if not id_municipio:
        return jsonify({"error": "El parámetro 'idMunicipio' es requerido."}), 400
    
    contenido, error = controlador.obtener_geojson(id_municipio)

    if error:
        return jsonify({"error": error}), 404

    return jsonify(contenido), 200

@mapas_bp.route('/mapas/municipios/filtros2', methods=['POST'])
def obtener_mapa_filtros2():
    """
    Endpoint para obtener un archivo GeoJSON según el ID proporcionado.
    """
    # Obtenemos los datos enviados en el cuerpo de la solicitud
    data = request.get_json()
    if not data:
        return jsonify({
            "status": "error",
            "message": "Se requiere un cuerpo JSON en la solicitud."
        }), 400

    # Extraemos los parámetros, asignando listas vacías por defecto
    delitos = data.get('delitos', [])
    anios = data.get('anios', [])
    meses = data.get('meses', [])
    municipios = data.get('municipios', [])

    # Llamamos al servicio controlador
    response = MapasControlador().select_delitos_vista(
        municipios, anios, meses, delitos
    )
    
    # Verificamos si hay errores en la respuesta
    if response.get("status") == "error":
        return jsonify({
            "message": response.get("message", "Error en la solicitud."),
            "errores": response.get("errores", []),
            "detalles": response.get("detalles", None),
        }), 400

    # Respuesta exitosa
    return jsonify(response), 200

@mapas_bp.route('/mapas/municipios/filtros', methods=['POST'])
def obtener_mapa_filtros():
    """
    Endpoint para obtener un archivo GeoJSON según el ID proporcionado.
    """
    # Obtenemos los datos enviados en el cuerpo de la solicitud
    data = request.get_json()
    if not data:
        return jsonify({
            "status": "error",
            "message": "Se requiere un cuerpo JSON en la solicitud."
        }), 400

    # Extraemos los parámetros, asignando listas vacías por defecto
    subtiposDelitos = data.get('subtiposDelitos', [])
    modalidades = data.get('modalidades', [])
    anios = data.get('anios', [])
    meses = data.get('meses', [])
    municipios = data.get('municipios', [])

    # Llamamos al servicio controlador
    response = controlador.select_vista_con_geojson(
        municipios, anios, meses, subtiposDelitos, modalidades
    )
    
    # Validar si hubo errores
    if "errores" in response:
        return jsonify({
            "errores": response["errores"],
        }), 400  # Código 400 si los filtros están mal

    # Respuesta exitosa
    return jsonify(response), 200

@mapas_bp.route('/estadisticas-delitos/fuentes-externas/consulta-por-filtros-mapas-municipios', methods=['POST'])
def obtener_mapa_fe():
    # Obtenemos los datos enviados en el cuerpo de la solicitud
    data = request.get_json()
    if not data:
        return jsonify({
            "status": "error",
            "message": "Se requiere un cuerpo JSON en la solicitud."
        }), 400
    
    # Extraemos los parámetros, asignando listas vacías por defecto
    municipios = data.get('municipios', [])
    anios = data.get('anios', [])
    meses = data.get('meses', [])

    # Llamamos al servicio controlador
    response = controlador.select_vista_con_geojson_fe(
        municipios, anios, meses
    )
    # Validar si hubo errores
    if "errores" in response:
        return jsonify({
            "errores": response["errores"],
        }), 400  # Código 400 si los filtros están mal

    # Respuesta exitosa
    return jsonify(response), 200

@mapas_bp.route('/mapas/estado', methods=['GET'])
def obtener_mapa_estado():
    """
    Endpoint para obtener un archivo GeoJSON según el ID proporcionado.
    """
    # Leer el parámetro de consulta
    id_estado = request.args.get('idEstado')

    # Validar si el parámetro se proporcionó
    if not id_estado:
        return jsonify({"error": "El parámetro 'idEstado' es requerido."}), 400
    
    contenido, error = controlador.obtener_geojson_estado(id_estado)

    if error:
        return jsonify({"error": error}), 404

    return jsonify(contenido), 200


@mapas_bp.route('/estadisticas-delitos/fuentes-externas/consulta-por-filtros-mapas-entidad', methods=['POST'])
def obtener_mapa_fe_en():
    # Obtenemos los datos enviados en el cuerpo de la solicitud
    data = request.get_json()
    if not data:
        return jsonify({
            "status": "error",
            "message": "Se requiere un cuerpo JSON en la solicitud."
        }), 400
    
    # Extraemos los parámetros, asignando listas vacías por defecto
    entidades = data.get('entidades', [])
    anios = data.get('anios', [])
    meses = data.get('meses', [])

    # Llamamos al servicio controlador
    response = controlador.select_vista_con_geojson_fe_en(
        entidades, anios, meses
    )
    # Validar si hubo errores
    if "errores" in response:
        return jsonify({
            "errores": response["errores"],
        }), 400  # Código 400 si los filtros están mal

    # Respuesta exitosa
    return jsonify(response), 200
