


'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''

from flask import Blueprint, request, jsonify
from app.controladores.fun_time import *                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
Demo_Time = Blueprint('Demo_Time', __name__)        


# Esta funcion regresa el dia y la hora actuales
@Demo_Time.route("/fecha",methods=["GET"])
def Give_Day():

    # Realizamos el procesamiento de la informacion
    try:
        Dia = Check_day()
        response = jsonify({"respuesta": Dia})
        response.status_code = 200
        return response        
    except:

        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response


# Esta funcion regresa el dia de hoy sumado de numdia dias y nummes meses        
@Demo_Time.route("/sumfecha",methods=["GET"])
def Sum_Days():

    # Recibimos la informacion y la revisamos para identificar si es correcta
    Flag = Rev_info_sd(request.args)
    
    if Flag == True:

        # Realizamos el procesamiento de la informacion
        try:
            Dia = Sumar_days(request.args)
            response = jsonify({"respuesta": Dia})
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
@Demo_Time.route("/sumhoras",methods=["POST"])
def Sum_Horas():

    # Recibimos la informacion y la revisamos para identificar si es correcta
    Info = request.get_json()
    Flag = Rev_info_sh(Info)
    
    if Flag == True:

        # Realizamos el procesamiento de la informacion
        try:
            Dia = Sumar_hours(Info)
            response = jsonify({"respuesta": Dia})
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


# Esta funcion regresa la fecha de mañana
@Demo_Time.route("/fecha_tomorrow",methods=["GET","PUT"])
def fecha_tomorrow():

    # Realizamos el procesamiento de la informacion
    try:
        Tomorrow = Sumar_hours({ "numhour" : 4, "nummin": 5})
        response = jsonify({"respuesta": Tomorrow})
        response.status_code = 200
        return response        
    except:

        response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
        response.status_code = 500
        return response