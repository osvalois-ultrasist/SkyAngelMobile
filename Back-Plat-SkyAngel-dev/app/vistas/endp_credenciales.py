
'''
    Este script contiene un ejemplo de endpoints 
    
    La siguiente liga contiene algunas codigos de respuesta y cuando usarlos: https://http.cat/
'''
from flask import Blueprint, request, jsonify
from app.controladores.fun_credenciales import *
from flask_jwt_extended import (
    JWTManager, create_access_token, jwt_required, get_jwt_identity
)

# Se crea la coleccion de endpoints                           
credenciales = Blueprint('credenciales', __name__)        

# Esta endpoint registra un usuario
@credenciales.route("/registro_user",methods=["POST"])
def registrar():
    
    # Recibimos la informacion y la revisamos para identificar si es correcta
    Info = request.get_json()
    Flag = Rev_info_Registro(Info)    
    
    if Flag == True:
        
        try:
            # Reviso si el usuario existe
            Existe = Rev_UserName(Info)
            if Existe == True:
                response = jsonify({"error": "El correo ya esta registrado"})
                response.status_code = 409
                return response

            # Si no existe lo registro en la bd, lo registro
            Insertar_Usuario(Info)
            response = jsonify({"Mensaje": "El usuario fue registrado exitosamente"})
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

# Este endpoint verifica la informacion del usuario para regresar un token
@credenciales.route("/login_user",methods=["POST"])
def login():
    
    # Recibimos la informacion y la revisamos para identificar si es correcta
    Info = request.get_json()
    Flag = Rev_info_Login(Info)    
    
    if Flag == True:
        
        try:
            # Reviso si el correo existe
            Existe = Rev_UserName(Info)
            if Existe == False:
                response = jsonify({"error": "Usario o contraseña incorrectos"})
                response.status_code = 404
                return response

            # Si existe el correo, compruebo sus credenciales 
            mensaje,code = Check_Credenciales(Info)
            response = jsonify(mensaje)
            response.status_code = code
            return response 
        except Exception as e:
            print(f"Error: {e}")
            response = jsonify({"respuesta": 'Fallo en el procesamiento de la informacion'})
            response.status_code = 500
            return response                          
    else:
        response = jsonify({"respuesta":'Argumentos incorrectos'})
        response.status_code = 400
        return response

# Este endpoint verifica si el token utilizado sigue siendo valido
@credenciales.route("/check_token",methods=["GET"])
@jwt_required()
def Check_token():
    response = jsonify({"mensaje": 'El token de acceso es valido'})
    response.status_code = 200
    return response     