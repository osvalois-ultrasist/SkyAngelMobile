'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_login import *    # Importamos todas las funciones desarrolladas para esta coleccion

# Se crea la coleccion de endpoints                           
registro = Blueprint('registro', __name__)        

# Esta funcion realiza el registro de usuarios
@registro.route("/registrar_usuario",methods=["POST"])
def registrar():
    if request.method == 'POST':
        data = request.get_json()
        usuario = data.get('usuario')
        correo = data.get('correo')
        password = data.get('password')

        reg = Login()
        resultado_registro, status_code = reg.registrar_usuario(usuario, correo, password)
        return resultado_registro, status_code
    
# Esta función valida la existencia del correo en la base de datos
@registro.route("/validar_correo",methods=["POST"])
def validar():
    if request.method == 'POST':
        data = request.get_json()
        correo = data.get('correo')
        reg = Login()
        resultado_validacion, status_code = reg.validar_usuario(correo)
        return resultado_validacion, status_code