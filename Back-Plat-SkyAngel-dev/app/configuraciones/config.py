'''
    En este documento crea la clase Config que contiene todas la configuraciones y llaves
'''
import boto3
import os
# Definimos tiempo de scheduler de status alerta
TIEMPO_ALERTA_ACTIVA = 2

# Crear cliente SSM
ssm_client = boto3.client('ssm', region_name='us-east-1')

# Obtenengo los parametros no sencibles
Parametros = ['SKYBACK_DB_HOST','SKYBACK_DB_NAME','SKYBACK_DB_PORT','SKYBACK_DB_USER','SKYBACK_DEBUG','SKYBACK_PORT','SKYBACK_HOST','SKYBUCKET', '/skyAngel/config/ip_Valhalla']
ParamNSen = ssm_client.get_parameters(
    Names=Parametros,
    WithDecryption=False  # Cambia a True si algunos son SecureString
)
# Obtengo los parmetros sensibles
ParamSen = ssm_client.get_parameter(Name='SKYBACK_DB_PASSWORD', WithDecryption=True)

# Organizo la informacion
Valores = {}
for num_par in range(len(Parametros)):
    Valores[ParamNSen['Parameters'][num_par]['Name']] = ParamNSen['Parameters'][num_par]['Value']
Valores[ParamSen['Parameter']['Name']] = ParamSen['Parameter']['Value']

## Otenemos los parametros que se utilizan para el socket
Parametros_Socket = ['SKYBACK_SOCKET_LANG', 'SKYBACK_SOCKET_LANGUAGE', 'SKYBACK_SOCKET_LC_ALL']
ParamNSen = ssm_client.get_parameters(
    Names=Parametros_Socket,
    WithDecryption=False  # Cambia a True si algunos son SecureString
)
for num_par in range(len(Parametros_Socket)):
    Valores[ParamNSen['Parameters'][num_par]['Name']] = ParamNSen['Parameters'][num_par]['Value']
Valores[ParamSen['Parameter']['Name']] = ParamSen['Parameter']['Value']


# Creo la clase con las variables 
class Config():
    
    # Definimos el ambiente
    DEBUG = Valores["SKYBACK_DEBUG"]
    PORT = Valores["SKYBACK_PORT"]
    HOST = Valores["SKYBACK_HOST"]
    
    # Definimos los parametros para la BD
    DB_HOST = Valores['SKYBACK_DB_HOST']
    DB_NAME = Valores['SKYBACK_DB_NAME']
    DB_USER =Valores['SKYBACK_DB_USER']
    DB_PASSWORD = Valores['SKYBACK_DB_PASSWORD']
    DB_PORT = Valores['SKYBACK_DB_PORT']
    
    # Definimos la ruta del Valhalla
    VALHALLA_HOST = Valores['/skyAngel/config/ip_Valhalla']

    # Definimos el bucket
    S3_BUCKET = Valores['SKYBUCKET']

    # Claves 
    BACK_JWT_SECRET_KEY = 'SkyBackEndSecretLml'
    # Variables de socket
    SOCKET_LANG = Valores['SKYBACK_SOCKET_LANG']
    SOCKET_LANGUAGE = Valores['SKYBACK_SOCKET_LANGUAGE']
    SOCKET_LC_ALL = Valores['SKYBACK_SOCKET_LC_ALL']

# Valores de parametros socket en variables de entorno
os.environ['LC_ALL'] = Valores['SKYBACK_SOCKET_LC_ALL']
os.environ['LANGUAGE'] = Valores['SKYBACK_SOCKET_LANGUAGE']
os.environ['LANG'] = Valores['SKYBACK_SOCKET_LANG']