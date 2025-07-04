


'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''

from flask import Blueprint, request, jsonify
from app.controladores.fun_fargate import *                     # Importamos todas las funciones desarrolladas para esta coleccion


# Se crea la coleccion de endpoints                           
Prueba_Fargate = Blueprint('Prueba_Fargate', __name__)        


# Esta funcion regresa el dia y la hora actuales
@Prueba_Fargate.route("/prueba-fargate",methods=["GET"])
def TestFargate():

    # Realizamos el procesamiento de la informacion
    try:
        response = jsonify({"respuesta": "Hay conexion con la aplicacion"})
        response.status_code = 200
        return response        
    except:

        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response

# Esta funcion prueba la coneccion a la base de datos
@Prueba_Fargate.route("/prueba-basedatos",methods=["GET"])
def TestDB_Fargate():

    # Realizamos el procesamiento de la informacion
    Flag,Result = Test_DB_Conection()
    if Flag:
        response = jsonify({"respuesta":Result})
        response.status_code = 200
        return response        
    else:
        response = jsonify({'respuesta':Result})
        response.status_code = 500
        return response

# Esta funcion prueba la coneccion al s3
@Prueba_Fargate.route("/prueba-s3",methods=["GET"])
def TestS3_Fargate():

    # Realizamos el procesamiento de la informacion
    Flag,Result = Test_s3_Conection()
    if Flag:
        response = jsonify({"respuesta":Result})
        response.status_code = 200
        return response        
    else:
        response = jsonify({'respuesta':Result})
        response.status_code = 500
        return response

# Esta funcin ace una prueba de conexion al valhalla
@Prueba_Fargate.route("/prueba-valhalla",methods=["GET"])
def Test_Val():
    Resp = Test_Valhalla()
    response = jsonify({"respuesta":Resp})
    return response