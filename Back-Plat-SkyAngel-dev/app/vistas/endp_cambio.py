


'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify, session
from app.controladores.fun_login import *                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
cambio_pass = Blueprint('cambio_pass', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@cambio_pass.route("/cambio_password",methods=["POST"])
def cambio_con():
    if request.method == 'POST':
        data = request.get_json()
        correo = data.get('correo')
        codigo = data.get('codigo')
        password = data.get('password')
        
        cam = Login()
        resultado, status_code = cam.cambio_password(correo,codigo,password)
        return resultado, status_code