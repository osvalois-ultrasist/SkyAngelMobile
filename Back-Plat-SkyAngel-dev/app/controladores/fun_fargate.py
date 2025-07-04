


'''
    Este script contiene las funciones con las que se realiza el endpont de la coleccion 'Consulta'
'''
from app.configuraciones.config import Config
from app.modelos.conexion_s3 import Conexion_S3
import requests

# Esta funcion prueba la conexion con la base de datos
def Test_DB_Conection():
    
    import psycopg2 
    try:
        conn = psycopg2.connect(
                dbname=Config.DB_NAME,
                user=Config.DB_USER,
                password=Config.DB_PASSWORD,
                host=Config.DB_HOST,
                port=Config.DB_PORT
                )
        return True,'Conexion exitosa a la BD con IP: '+str(Config.DB_HOST)
    
    except:
        return False,{'message':'error de conexion'+ str(Config.DB_HOST)}
    
# Esta funcion prueba la conexion al se
def Test_s3_Conection():
    
    Conn = Conexion_S3()
    return Conn.CheckBucket(Config.S3_BUCKET)

# Esta funcion hace una prueba de conexion al valhalla
def Test_Valhalla():
    valhalla_host = Config.VALHALLA_HOST
    url = valhalla_host+'/status'   
    resp = requests.get(url)
    if resp.status_code == 200:
        return 'hay conexion con '+url
    else:
        return 'Fallo en la conexion ' + url
    
    