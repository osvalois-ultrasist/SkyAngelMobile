


'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_login import *                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
recuperacion = Blueprint('recuperacion', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@recuperacion.route("/login_reset",methods=["POST"])
def recup():
    if request.method == 'POST':
        data = request.get_json()
        correo = data.get('correo')
        
        rec = Login()
        resultado, status_code = rec.recuperacion_mail(correo)
        return resultado, status_code