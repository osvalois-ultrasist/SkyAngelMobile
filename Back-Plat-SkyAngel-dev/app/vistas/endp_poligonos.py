


'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''

from flask import Blueprint, request, jsonify
from app.controladores.fun_poligonos import *                     # Importamos todas las funciones desarrolladas para esta coleccion
import gzip

# Se crea la coleccion de endpoints                           
Poligonos = Blueprint('Poligonos', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@Poligonos.route("/get-poligono",methods=["POST"])
def Get_poligono():

    Info = request.get_json()
    Flag = Rev_info_GetPoligionos(Info)
    
    if Flag == True:

        # Realizamos el procesamiento de la informacion
        try:
            Poligono = GetPoligonos(Info)
            response = jsonify({"poligono": Poligono})
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
@Poligonos.route("/get-riesgo-ruta",methods=["POST"])
def Get_RiesgoRuta():

    # Recibimos la informacion y la revisamos para identificar si es correcta
    if request.headers.get('Content-Encoding') == 'gzip':
        compressed_data = request.get_data()
        decompressed_data = gzip.decompress(compressed_data)
        Info = json.loads(decompressed_data.decode('utf-8'))
        
        # Recibimos la informacion y la revisamos para identificar si es correcta
        Flag = Rev_info_georuta(Info)
        
        if Flag == True:

            # Realizamos el procesamiento de la informacion
            try:
                Poligono = Get_Geojson_Ruta(Info)
                response = jsonify({"geoRutaInfo": Poligono})
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

    else: 
        response = jsonify({"respuesta":'Información no comprimida'})
        response.status_code = 400
        return response

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@Poligonos.route("/get-riesgo-segtime",methods=["POST"])
def Get_Riesgo_SegTime():

    # Recibimos la informacion y la revisamos para identificar si es correcta
    if request.headers.get('Content-Encoding') == 'gzip':
        compressed_data = request.get_data()
        decompressed_data = gzip.decompress(compressed_data)
        Info = json.loads(decompressed_data.decode('utf-8'))
        
        # Recibimos la informacion y la revisamos para identificar si es correcta
        Flag = Rev_info_georuta(Info)
        
        if Flag == True:

            # Realizamos el procesamiento de la informacion
            try:
                Poligono = Get_Geojson_SegTime(Info)
                response = jsonify({"geoRutaInfo": Poligono})
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

    else: 
        response = jsonify({"respuesta":'Información no comprimida'})
        response.status_code = 400
        return response