'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''

from flask import Blueprint, request, jsonify
from app.controladores.fun_mallado_municipios import *                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
Mallado_Mun = Blueprint('Mallado_Mun', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@Mallado_Mun.route("/get-malladomun",methods=["POST"])
def Get_poligono():

    # Recibimos la informacion y la revisamos para identificar si es correcta
    Info = request.get_json()
    Flag = Rev_info_GetMalladoMun(Info)
    
    if Flag == True:

        # Realizamos el procesamiento de la informacion
        try:
            Mallado = GetMalladoMun(Info)
            response = jsonify({"respuesta": Mallado})
            response.status_code = 200
            return response        
        except:
            response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
            response.status_code = 500
            return response
    
    else:
        response = jsonify({"respuesta":'Argumentos incorrectos'})
        response.status_code = 400
        return response

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@Mallado_Mun.route("/get-malladomun-full",methods=["POST"])
def Get_poligono_full():

    # Recibimos la informacion y la revisamos para identificar si es correcta
    Info = request.get_json()
    Flag = Rev_info_GetMalladoMun(Info)
    
    if Flag == True:

        # Realizamos el procesamiento de la informacion
        try:
            Mallado = GetMalladoMun_Full(Info)
            response = jsonify({"respuesta": Mallado})
            response.status_code = 200
            return response        
        except:
            response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
            response.status_code = 500
            return response
    
    else:
        response = jsonify({"respuesta":'Argumentos incorrectos'})
        response.status_code = 400
        return response