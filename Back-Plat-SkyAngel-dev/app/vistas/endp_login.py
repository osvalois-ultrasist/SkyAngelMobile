


'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_login import *                     # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
login = Blueprint('login', __name__)        

# Esta funcion regresa el dia actual con una diferencia indicada de minutos y horas
@login.route("/login",methods=["POST"])
def logueo():
    if request.method == 'POST':
        data = request.get_json()
        usuario = data.get('usuario')
        password = data.get('password')

        logueo_user = Login()
        usuario_logeado, status_code = logueo_user.login_usuario(usuario, password)
        return usuario_logeado, status_code