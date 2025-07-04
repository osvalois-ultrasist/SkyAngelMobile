


'''
    Este script contiene las funciones con las que se realiza el endpont de la coleccion 'Consulta'
'''

from datetime import datetime
from datetime import timedelta
from app.configuraciones.config import Config
from psycopg2 import OperationalError

# Ruta: /fecha, Funcion: Give_Day-------------------------------------------------------------------------
# Esta funcion regresa el dia y la hora actual
def Check_day():
    
    Dia = datetime.today()
    return str(Dia)

# Ruta: /sumfecha, Funcion: Sum_Days-------------------------------------------------------------------------
# Esta funcion regresa el dia y hora actual sumando un dia 
def Sumar_days(Info):

    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: numdia, nummes = Info['numdia'],Info['nummes']
    except: return False
    
    # Convierto la informacion a enteros para poder manejarlos en suma
    numdia = timedelta(days=int(numdia))
    nummes = timedelta(days= 30*int(nummes))    
    Dia = datetime.today() + numdia + nummes
    
    return Dia

# Esta funcion revisa la informacion recibida para la funcion Sum_days():
def Rev_info_sd(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: numdia, nummes = Info['numdia'],Info['nummes']
    except: return False
    
    # Reviso que la informacion que contengan sean solo numeros enteros

    return True

# Ruta: /sumhoras, Funcion: Sum_Horas-------------------------------------------------------------------------
# Esta funcion regresa el dia y hora actual sumando algunas horas y minutos
def Sumar_hours(Info):

    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: numhoras, nummin = Info['numhours'],Info['nummin']
    except: return False
    
    # Convierto la informacion a enteros para poder manejarlos en suma
    numhoras = timedelta(hours=numhoras)
    nummin = timedelta(minutes=nummin)    
    Dia = datetime.today() + numhoras + nummin
    
    return Dia

# Esta funcion revisa la informacion recibida para la funcion Sum_hours():
def Rev_info_sh(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: numhoras, nummin = Info['numhours'],Info['nummin']
    except: return False
    
    # Reviso que la informacion que contengan sean solo numeros enteros

    return True

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