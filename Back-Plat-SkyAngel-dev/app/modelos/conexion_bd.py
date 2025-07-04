
'''
    Esta clase tiene la conexion y las operaciones basicas para realizar llamados a la bd
'''
import os
import json
import psycopg2
from app.configuraciones.config import Config

class Conexion_BD():
    
    def __init__(self):
        self.DB = Config.DB_NAME
        self.HOST = Config.DB_HOST
        self.PORT = Config.DB_PORT
        self.USER = Config.DB_USER
        self.PASSWORD = Config.DB_PASSWORD
        
    def conexion_bd(self):
        try: 
            conn = psycopg2.connect(
            dbname=self.DB,
            user=self.USER,
            password=self.PASSWORD,
            host=self.HOST,
            port=self.PORT
        )
            return conn
        except psycopg2.Error as e:
            print(f"Error: {e}")
            return f"Error al conectar a la base de datos: {e}"