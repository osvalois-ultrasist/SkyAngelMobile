

'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''

from flask import Blueprint, request, jsonify
from app.controladores.fun_mallados import *
from app.controladores.fun_time import *                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
Mallados = Blueprint('Mallados', __name__)        

# Este endpoint regresa un geojson la informacion y el delito requerido
@Mallados.route("/mallados/geocomportamiento",methods=["POST"])
def Geo_comportamiento():

    # Recibimos la informacion y la revisamos para identificar si es correcta
    Info = request.get_json()
    Flag = Rev_info_geocomportamiento(Info)
    
    if Flag == True:

        # Realizamos el procesamiento de la informacion
        try:
            # Generamos el geojson solicitado
            Respuesta = Get_Geojson_Delito(Info)
            response = jsonify({"GeoJson": Respuesta})
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

# Este endpoint regresa un geojson la informacion y el delito requerido de forma reducida (sin los poligionos con nula criminalidad)
@Mallados.route("/mallados/geocomportamiento-red",methods=["POST"])
def Geo_comportamiento_Red():

    # Recibimos la informacion y la revisamos para identificar si es correcta
    Info = request.get_json()
    Flag = Rev_info_geocomportamiento(Info)
    
    if Flag == True:

        # Realizamos el procesamiento de la informacion
        try:
            # Generamos el geojson solicitado
            Respuesta = Get_Geojson_Delito_Red(Info)
            response = jsonify({"GeoJson": Respuesta})
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

# Este endpoint regresa un geojson la informacion y el delito requerido
@Mallados.route("/mallados/georutavalues",methods=["POST"])
def Geo_Ruta_values():

    # Recibimos la informacion y la revisamos para identificar si es correcta
    Info = request.get_json()
    Flag = Rev_info_georuta(Info)
    
    if Flag == True:

        # Realizamos el procesamiento de la informacion
        try:
            # Generamos el geojson solicitado
            Respuesta = Get_Geojson_Ruta(Info)
            response = jsonify({"GeoCalculo": Respuesta})
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