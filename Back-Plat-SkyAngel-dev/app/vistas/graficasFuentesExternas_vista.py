import json
from app.controladores.graficasFuentesExternas_controlador import GraficasFuentesExternasService as sgfe
from flask import Blueprint, request, jsonify, Response

GraficasFuentesExternas_bp = Blueprint('graficaFuentesExternas', __name__)
@GraficasFuentesExternas_bp.route("/graficas/fuentes-externas/delitos-por-entidad-barras",methods=["POST"])
def graficaFuentesExternasDelitosPorEntidadBarras():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            json_data, code = sgfe(parametros).obtenerDatosDelitosPorEntidadBarras()
            return Response(json_data,status=code,mimetype='application/json; charset=utf-8')
    except Exception as e:
        response = json.dumps({"respuesta": 'Internal Server Error',
        "error":str(e)},ensure_ascii=False).encode('utf8')
        return Response(response,status=500,mimetype='application/json; charset=utf-8')

@GraficasFuentesExternas_bp.route("/graficas/fuentes-externas/delitos-por-municipio-barras",methods=["POST"])
def graficaFuentesExternasDelitosPorMunicipioBarras():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            json_data, code = sgfe(parametros).obtenerDatosDelitosPorMunicipioBarras()
            return Response(json_data,status=code,mimetype='application/json; charset=utf-8')
    except Exception as e:
        response = json.dumps({"respuesta": 'Internal Server Error',
        "error":str(e)},ensure_ascii=False).encode('utf8')
        return Response(response,status=500,mimetype='application/json; charset=utf-8')

@GraficasFuentesExternas_bp.route("/graficas/fuentes-externas/delitos-por-municipio-top20-barras",methods=["POST"])
def graficaFuentesExternasDelitosPorMunicipioTop20Barras():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            json_data, code = sgfe(parametros).obtenerDatosDelitosPorMunicipioTopBarras()
            return Response(json_data,status=code,mimetype='application/json; charset=utf-8')
    except Exception as e:
        response = json.dumps({"respuesta": 'Internal Server Error',
        "error":str(e)},ensure_ascii=False).encode('utf8')
        return Response(response,status=500,mimetype='application/json; charset=utf-8')

"""secBarrasAcum_bp = Blueprint('secBarrasAcum', __name__)
@secBarrasAcum_bp.route("/secBarrasAcum",methods=["POST"])
def secBarrasAcum():
    try:
        if request.method == 'POST':
            parametros = json.loads(request.data)
            response, code = secretariadoBarrasAcumService().obtenerDatos(parametros)
            return response, code
    except Exception as e:
        return ({"error": str(e)}), 500
"""