import psycopg2
import random
import string
import pytz # Instalar la libreria, es para el tiempo zona horaria -- pip install pytz
from datetime import datetime, timedelta
from flask import jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from app.configuraciones.config import Config
from app.modelos.conexion_bd import Conexion_BD

class Login():
    # # Variable global para almacenar el código de recuperación
    # codigo_recuperacion = None

    # Para el login
    def login_usuario(self,usuario, password):
        
        if not usuario or not password:
            return jsonify({"Error": "Faltan campos 'usuario' o 'password'"}), 400

        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            cursor.execute(
                "SELECT usuario, correo, password FROM usuarios WHERE usuario = %s",(usuario,)
            )
            rev = cursor.fetchone()
            if rev:
                if check_password_hash(rev[2], password):
                        #print("Inicio de sesion exitoso")
                    return jsonify({
                        "Mensaje": "Inicio de sesion exitoso",
                        "Usuario": rev[0],
                        "Correo": rev[1]
                    }), 200
                else:
                    return jsonify({"Error": "El usuario o el password son incorrectos"}), 401
            else:
                return jsonify({"Error": "El usuario o el password son incorrectos"}), 404
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return jsonify({"Error": "Error conexion del servidor"}), 500
        finally:
            # Cerrar la conexión y el cursor
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def validar_usuario(self, correo):
        if not correo:
            return jsonify({"error": "Falta campo 'correo'"}), 400

        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try:
            # Revisar si existe el correo en la base de datos
            cursor.execute(
                "SELECT usuario, correo FROM usuarios WHERE correo = %s",
                (correo,)
            )
            rev = cursor.fetchone()

            if rev:
                if rev[1] == correo:
                    return jsonify({
                        "auth": 1,
                        "mensaje": "Correo autorizado"
                    }), 200
            return jsonify({
                "auth": 0,
                "mensaje": "Correo no autorizado"
            }), 401

        except psycopg2.Error as e:
            print(f"Error al conectar a la base de datos: {e}")
            return jsonify({"error": "Error al conectar a la base de datos"}), 500

        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()


    def registrar_usuario(self,usuario,correo,password):

        if not usuario or not correo or not password:
            return jsonify({"error": "Faltan campos 'usuario', 'correo' o 'password'"}), 400

        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        hashed_password = generate_password_hash(password)
        try:
            #Para revisar el usuario y el correo antes de registro
            cursor.execute(
                "SELECT usuario, correo FROM usuarios WHERE usuario = %s OR correo = %s",
                (usuario, correo)
            )
            rev = cursor.fetchone()
            #Validar para corroborar si existe el usuario ó correo
            if rev:
                if rev[0] == usuario:
                    return jsonify({"error": "El usuario ya existe"}), 409
                if rev[1] == correo:
                    return jsonify({"error": "El correo ya esta registrado"}), 409

                #Inserción del nuevo usuario
            cursor.execute(
                "INSERT INTO usuarios (usuario, correo, password) VALUES (%s,%s,%s)",(usuario, correo, hashed_password)
            )
            conn.commit()
            return jsonify({"mensaje": "Usuario registrado exitosamente"}), 201
        except psycopg2.Error as e:
            print(f"Error al conectar a la base de datos: {e}")
            return jsonify({"error": "Error al conectar a la base de datos"}), 500
            # Cerrar la conexión y el cursor
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def generar_codigo(self,longitud=10):
        generar_caracteres = string.ascii_letters + string.digits
        return ''.join(random.choice(generar_caracteres) for _ in range(longitud))

    def recuperacion_mail(self,correo):
        if not correo:
            return jsonify({"error": "Faltan campos 'correo'"}), 400

        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        try: 
             #Para revisar el usuario y el correo antes de registro
            cursor.execute(
                "SELECT id_usuario, usuario FROM usuarios WHERE correo = %s",(correo,)
            )
            rev = cursor.fetchone()
            if rev:
                id_usuario = rev[0]
                codigo = self.generar_codigo()

                # Insertar el token en la tabla us_token con la marca de tiempo actual
                cursor.execute(
                    "INSERT INTO us_token (id_usuario, token, caduca) VALUES (%s, %s, CURRENT_TIMESTAMP) ON CONFLICT (id_usuario) DO UPDATE SET token = EXCLUDED.token, caduca = EXCLUDED.caduca",
                    (id_usuario, codigo)
                )
                conn.commit()

                return jsonify({"mensaje": "Codigo generado correctamente", "codigo": codigo}), 200
            else:
                return jsonify({"mensaje": "No existe el correo en la base de datos"}), 404
        except psycopg2.Error as e:
            print(f"Error al conectar a la base de datos: {e}")
            return jsonify({"error": "Error al conectar a la base de datos"}), 500
                # Cerrar la conexión y el cursor
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    def cambio_password(self,correo,codigo,password):
        if not correo or not codigo or not password:
            return jsonify({"error": "Faltan datos del correo, codigo o password"}), 400

        conn = Conexion_BD().conexion_bd()
        cursor = conn.cursor()
        hashed_password = generate_password_hash(password)
        try:
            #Para revisar el usuario y el correo antes de registro
            cursor.execute(
                "SELECT id_usuario, usuario FROM usuarios WHERE correo = %s",(correo,)
            )
            rev = cursor.fetchone()
            if rev:
                id_usuario = rev[0]

                # Verificar el token y su validez temporal
                cursor.execute(
                    "SELECT token, caduca FROM us_token WHERE id_usuario = %s AND token = %s", (id_usuario, codigo)
                )
                token_info = cursor.fetchone()
                if token_info:
                    token, caduca = token_info
                    # Convertir timestamp a naive datetime
                    caduca = caduca.replace(tzinfo=None)
                    # Verificar si el token ha expirado
                    if datetime.now() - caduca > timedelta(minutes=5):
                        return jsonify({"error": "Codigo de recuperacion ha expirado"}), 400

                    # Actualizar la contraseña del usuario
                    cursor.execute(
                        "UPDATE usuarios SET password = %s WHERE correo = %s",(hashed_password, correo)
                    )
                    conn.commit()

                    # Eliminar el token después de usarlo
                    cursor.execute(
                        "DELETE FROM us_token WHERE id_usuario = %s", (id_usuario,)
                    )
                    conn.commit()

                    return jsonify({"mensaje": "Password actualizado correctamente"}), 200
                else:
                    return jsonify({"error": "Codigo de recuperacion incorrecto o se ha expirado"}), 400
            else:
                return jsonify({"error": "El correo ingresado no existe"}), 400
        except psycopg2.Error as e:
            print(f"Error al conectar a la base de datos: {e}")
            return jsonify({"error": "Error al conectar a la base de datos"}), 500
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()