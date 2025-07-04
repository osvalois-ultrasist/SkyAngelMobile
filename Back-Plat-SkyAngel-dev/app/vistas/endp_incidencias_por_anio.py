'''
    Este script contiene un endpoint que conecta las gráficas
'''
import json
from flask import Blueprint, request, jsonify
from app.controladores.fun_incidencias_por_anio import Incidencias_por_anio_service                 # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
incidencias = Blueprint('incidencias', __name__)        


# Esta funcion regresa el dia y la hora actuales
@incidencias.route("/incidencias",methods=["GET"])
def incidencias_por_anio_1():
    # Aquí se va a llamar al controlador 
    if request.method == 'GET':
        with open('C:/Users/MariaGR/my-app/public/result.json', 'r') as f:
            response = json.load(f)
        #response= Incidencias_por_anio_service().grafica('C:/Users/MariaGR/my-app/public/Delitos_Full.json')
    return response


@incidencias.route("/incidencias",methods=["POST"])
def incidencias_por_anio():
    # Aquí se va a llamar al controlador 
    if request.method == 'POST':
        parametros = json.loads(request.data)
        response, code = Incidencias_por_anio_service().grafica(parametros)
    return response, code
"""
@incidencias.route("/incidencias",methods=["GET"])
def select_incidentes():
    # Aquí se va a llamar al controlador 
    if request.method == 'GET':
        response, status_code = Incidencias_por_anio_service().incidentes()
        return response, status_code
    return response"""