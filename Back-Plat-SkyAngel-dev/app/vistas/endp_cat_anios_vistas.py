'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_cat_anios import Cat_anios_service # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
cat_anios = Blueprint('cat_anios', __name__)

@cat_anios.route("/cat_anios",methods=["GET"])
def cat_anios_get():
    if request.method == 'GET':
        response, status_code = Cat_anios_service().select_distinct_anios()
        return response, status_code


@cat_anios.route("/fuentes-externas/anios",methods=["GET"])
def cat_anios_fe_get():
    if request.method == 'GET':
        response, status_code = Cat_anios_service().select_distinct_anios_fe()
        return response, status_code
    
@cat_anios.route("/skyangel/anios",methods=["GET"])
def cat_anios_sa_get():
    if request.method == 'GET':
        response, status_code = Cat_anios_service().select_distinct_anios_sa()
        return response, status_code