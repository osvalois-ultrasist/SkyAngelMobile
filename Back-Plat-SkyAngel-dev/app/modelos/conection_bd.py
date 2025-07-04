from app.configuraciones.config import Config
import psycopg2
import pandas as pd
# Creamos una clase para generar la conexion al WH
class Conection_BD():
    
    def __init__(self):
        # Inicializo las variables 
        self.DB_NAME = Config.DB_NAME
        self.DB_USER = Config.DB_USER
        self.DB_PASS = Config.DB_PASSWORD
        self.DB_HOST = Config.DB_HOST
        self.DB_PORT = Config.DB_PORT
        
        # Inicializo la conexion
        self.Get_Conexion()
    
    # Este metodo abre la conexion con la BD
    def Get_Conexion(self):
        
        self.connection = psycopg2.connect(
            dbname=self.DB_NAME,
            user=self.DB_USER,
            password=self.DB_PASS,
            host=self.DB_HOST,
            port=self.DB_PORT
        )
    
    # Este metodo ejecuta un query, organiza la respuesta y cierra la conexion
    def Run_query(self,query):
        
        # Establesco una conexion
        self.Get_Conexion()
        
        # Crear un cursor y ejecuto la consulta
        cursor = self.connection.cursor()
        cursor.execute(query, (1,))
        # Organizo los resultados
        registros = cursor.fetchall()
        column_names = [desc[0] for desc in cursor.description]
        Resultado = pd.DataFrame(registros,columns=[column_names])
        # Cerrar la conexión y el cursor
        cursor.close()
        self.connection.close()
        
        Datos = pd.DataFrame()
        for campo in Resultado.keys():
            Datos[campo[0]] = Resultado[campo[0]]
        
        return Datos

    # Este metodo ejecuta un query de insert, organiza la respuesta y cierra la conexion
    def Run_InsertUser(self,usuario, correo, hashed_password):
        
        # Establesco una conexion
        self.Get_Conexion()
        
        # Crear un cursor y ejecuto la consulta
        cursor = self.connection.cursor()
        cursor.execute("INSERT INTO usuarios (usuario, correo, password) VALUES (%s,%s,%s)",(usuario, correo, hashed_password))
        self.connection.commit()

        # Cerrar la conexión y el cursor
        cursor.close()
        self.connection.close()